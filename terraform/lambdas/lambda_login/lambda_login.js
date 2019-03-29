console.log('Loading function');
global.fetch = require('node-fetch')

const AWS_REGION_STRING = process.env.AWS_REGION
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID
const userPoolId = process.env.COGNITO_USER_POOL
const clientId = process.env.USER_POOL_CLIENT_ID
// const COGNITO_URI = `https://cognito-idp.${AWS_REGION_STRING}.amazonaws.com/${COGNITO_USER_POOL}`
const DEBUG_ENABLED = process.env.DEBUG_ENABLED.toUpperCase() == 'TRUE'

const AWS = require('aws-sdk')
AWS.config.update({
  region: AWS_REGION_STRING
})

const AmazonCognitoIdentity = require('amazon-cognito-identity-js')

/**
 * Demonstrates a simple HTTP endpoint using API Gateway. You have full
 * access to the request and response payload, including headers and
 * status code.
 */
exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const done = (res) => callback(null, {
    statusCode: '200',
    body: JSON.stringify(res),
    headers: {
      'Content-Type': 'application/json',
    },
  });

  const notFound = (res) => callback(null, {
    statusCode: '404',
    body: JSON.stringify(res),
    headers: {
      'Content-Type': 'application/json',
    },
  });

  const notAuth = (res) => callback(null, {
    statusCode: '403',
    body: JSON.stringify(res),
    headers: {
      'Content-Type': 'application/json',
    },
  });




  let body = JSON.parse(event.body)
  let userName = body.username
  let userPassword = body.password
  if (userName && userPassword) {

    //get token
    const authenticationData = {
      Username: userName,
      Password: userPassword
    }


    const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData)

    const poolData = {
      UserPoolId: userPoolId,
      ClientId: clientId
    }

    const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData)

    const userData = {
      Username: userName,
      Pool: userPool
    }

    const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData)


    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess: function (result) {
        // console.log('result', JSON.stringify(result, null, 2));

        // var accessToken = result.getAccessToken().getJwtToken();
        // console.log('accessToken', accessToken)

        let jwtWithAttributes = result.idToken.jwtToken
        //let payload = result.idToken.payload

        console.log('', jwtWithAttributes)
        // console.log('JWT: ', jwtWithAttributes)
        // console.log('payload', JSON.stringify(payload, null, 2));

        done({
          token: jwtWithAttributes
        });
      },

      onFailure: function (error) {
        console.log('error', JSON.stringify(error, null, 2));
        notAuth({
          error: "Unauthorized user"
        })
      }

    })


  } else {
    notFound({
      error: "Service not found"
    })
  }



};



