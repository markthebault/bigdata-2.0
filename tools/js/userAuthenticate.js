global.fetch = require('node-fetch')

const AWS_REGION_STRING = process.env.AWS_REGION

const AWS = require('aws-sdk')
AWS.config.update({
  region: AWS_REGION_STRING
})

const userName = process.env.USER_NAME
const userPassword = process.env.USER_PASSWORD
const userPoolId = process.env.USER_POOL_ID
const clientId = process.env.USER_POOL_CLIENT_ID

const authenticationData = {
  Username: userName,
  Password: userPassword
}

const AmazonCognitoIdentity = require('amazon-cognito-identity-js')
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
    let payload = result.idToken.payload

    console.log('', jwtWithAttributes)
    // console.log('JWT: ', jwtWithAttributes)
    // console.log('payload', JSON.stringify(payload, null, 2));
  },

  onFailure: function (error) {
    console.log('error', JSON.stringify(error, null, 2));
  }

})
