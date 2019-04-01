console.log('Loading function');

const AWS_REGION_STRING = process.env.AWS_REGION
const COGNITO_USER_POOL = process.env.COGNITO_USER_POOL
const COGNITO_URI = `https://cognito-idp.${AWS_REGION_STRING}.amazonaws.com/${COGNITO_USER_POOL}`
const DEBUG_ENABLED = process.env.DEBUG_ENABLED.toUpperCase() == 'TRUE'


const doc = require('dynamodb-doc');
const jwt = require('jsonwebtoken')
const router = require('aws-lambda-router');





exports.handler = router.handler({
  // for handling an http-call from an AWS API Gateway proxyIntegration we provide the following config:
  proxyIntegration: {
    routes: [
      {
        // request-path-pattern with a path variable:
        path: '/say-hello/:id',
        method: 'GET',
        // we can use the path param 'id' in the action call:
        action: (request, context) => doAnything(request)
      }
    ]
  }
});

function doAnything(request) {
  message = "Hello " + request.paths.id + " !"
  if (DEBUG_ENABLED) console.log('request: ', JSON.stringify(request, null, 2))

  iamRoles = jwtExtractRole(request)

  return {
    statusCode: '200',
    body: JSON.stringify({
      message: message,
      roles: iamRoles
    })
  }
}

function jwtExtractRole(request) {
  let jwtEncoded = request.multiValueHeaders.Authorization[0]
  console.log('jwtEncoded: ', JSON.stringify(jwtEncoded, null, 2))

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
  if (DEBUG_ENABLED) console.log('cognitoRoles: ', JSON.stringify(jwtDecoded, null, 2))

  return cognitoRoles

}