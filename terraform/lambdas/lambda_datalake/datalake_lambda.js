console.log('Loading function');

const AWS_REGION_STRING = process.env.AWS_REGION
const DYNAMO_LANDING_TABLE_NAME = process.env.DYNAMO_LANDING_TABLE_NAME
const COGNITO_USER_POOL = process.env.COGNITO_USER_POOL
const S3_LANDING_BUCKET = process.env.S3_LANDING_BUCKET
const COGNITO_URI = `https://cognito-idp.${AWS_REGION_STRING}.amazonaws.com/${COGNITO_USER_POOL}`
const DEBUG_ENABLED = process.env.DEBUG_ENABLED.toUpperCase() == 'TRUE'


const doc = require('dynamodb-doc');
const jwt = require('jsonwebtoken')
const router = require('aws-lambda-router');
const AWS = require('aws-sdk');


var sts = new AWS.STS();
var ddb = new AWS.DynamoDB();




exports.handler = router.handler({
  // for handling an http-call from an AWS API Gateway proxyIntegration we provide the following config:
  proxyIntegration: {
    routes: [
      {
        // request-path-pattern with a path variable:
        path: '/say-hello/:id',
        method: 'GET',
        action: (request, context) => doAnything(request)
      },
      {
        // request-path-pattern with a path variable:
        path: '/declare-dataset',
        method: 'POST',
        action: (request, context) => declareDataset(request)
      }
    ]
  }
});

async function declareDataset(request) {
  let dataset = request.body.dataset
  let datasetPath = request.body.datasetPath
  let datasetMetadata = request.body.metadata
  const datasetKey = datasetPath + dataset

  if (DEBUG_ENABLED) console.log('dataset: ', JSON.stringify(dataset, null, 2))
  if (DEBUG_ENABLED) console.log('datasetPath: ', JSON.stringify(datasetPath, null, 2))


  if (datasetPath.split("/").length <= 2) {
    return error("Path must be like '/somepath/' or '/some/path/to/my/dataset/' it should start and end with '/' and contains only [A-z1-9] and hyphens")
  }
  else {

    roles = jwtExtractRoles(request)
    user = jwtExtractUser(request)

    let sts_params = {
      RoleArn: roles[0],
      RoleSessionName: "stsAssumeSession"
    };


    let data = await sts.assumeRole(sts_params, function (err, data) {
      if (err) {
        console.log(err, err.stack);
        return {}
      } else {
        if (DEBUG_ENABLED) console.log('data: ', JSON.stringify(data, null, 2))
        return data


        //Once we've gotten the temp credentials, let's apply them
        // AWS.config.credentials = new AWS.TemporaryCredentials({ RoleArn: sts_params.RoleArn });

        // //Let's get the s3 object with the new role
        // s3.getObject(s3_params, function (err, result) {
      }
    }).promise();

    let credentials = {
      AccessKeyId: data.Credentials.AccessKeyId,
      SecretAccessKey: data.Credentials.SecretAccessKey,
      SessionToken: data.Credentials.SessionToken,
      Expiration: data.Credentials.Expiration
    }


    const url = "s3://" + S3_LANDING_BUCKET + datasetKey

    //Register landing dataset in dynamo
    var params = {
      TableName: DYNAMO_LANDING_TABLE_NAME,
      Item: {
        'dataset_key': { S: datasetKey },
        'uri': { S: url },
        'metadata': { S: datasetMetadata },
        'user': { S: user },
        'algo': { S: 'ETL_IMPORT' },
        'algo-params': {
          S: JSON.stringify({
            inputFileType: 'csv',
            outputFileType: 'parket',
            partition: 'NONE',
            partitionSize: '32Mb'
          })
        },
        'format': { S: 'csv' }
      }
    };
    if (DEBUG_ENABLED) console.log('dynamoparams: ', JSON.stringify(params, null, 2))

    // Call DynamoDB to add the item to the table
    var response = await ddb.putItem(params, function (err, data) {
      if (err) {
        console.log("Error", err);
      } else {
        console.log("Success", data);
      }
    }).promise();
    if (DEBUG_ENABLED) console.log('dynamoresponse: ', JSON.stringify(response, null, 2))


    return done({
      dataset: dataset,
      datasetPath: datasetPath,
      credentials: credentials,
      url: url
    })
  }
}

function doAnything(request) {
  message = "Hello " + request.paths.id + " !"
  if (DEBUG_ENABLED) console.log('request: ', JSON.stringify(request, null, 2))

  iamRoles = jwtExtractRoles(request)

  return done({
    message: message,
    roles: iamRoles
  })

}

function jwtExtractRoles(request) {
  let jwtEncoded = request.multiValueHeaders.Authorization[0]
  if (DEBUG_ENABLED) console.log('jwtEncoded: ', JSON.stringify(jwtEncoded, null, 2))

  let jwtDecoded = jwt.decode(jwtEncoded)
  if (DEBUG_ENABLED) console.log('jwtDecoded: ', JSON.stringify(jwtDecoded, null, 2))

  let userId = jwtDecoded.sub
  if (DEBUG_ENABLED) console.log('userId: ', userId)
  principalId = `user|${userId}`

  if (jwtDecoded.iss != COGNITO_URI) {
    if (DEBUG_ENABLED) console.log("FAILUE: COGNITO_URI does not match JWT")
    throw "Token not from cognito";
  }

  let expirationDate = new Date(jwtDecoded.exp * 1000)
  if (expirationDate < new Date()) {
    if (DEBUG_ENABLED) console.log("FAILURE: JWT EXPIRED")
    throw "Token expired"
  }

  let cognitoRoles = jwtDecoded["cognito:roles"]
  if (DEBUG_ENABLED) console.log('cognitoRoles: ', JSON.stringify(cognitoRoles, null, 2))

  return cognitoRoles

}

function jwtExtractUser(request) {
  let jwtEncoded = request.multiValueHeaders.Authorization[0]
  if (DEBUG_ENABLED) console.log('jwtEncoded: ', JSON.stringify(jwtEncoded, null, 2))

  let jwtDecoded = jwt.decode(jwtEncoded)
  if (DEBUG_ENABLED) console.log('jwtDecoded: ', JSON.stringify(jwtDecoded, null, 2))

  let userId = jwtDecoded.sub
  if (DEBUG_ENABLED) console.log('userId: ', userId)
  return `user|${userId}`

}





function done(body) {
  return {
    statusCode: '200',
    body: JSON.stringify(body),
    headers: {
      'Content-Type': 'application/json',
    }
  }
}
function error(errorMessage) {
  return {
    statusCode: '501',
    body: {
      error: errorMessage
    },
    headers: {
      'Content-Type': 'application/json',
    }
  }
}

