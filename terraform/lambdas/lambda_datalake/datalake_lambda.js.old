console.log('Loading function');

const doc = require('dynamodb-doc');



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

  if (event.pathParameters == null || event.pathParameters == "null") {
    notFound({
      error: "Service not found"
    })
  }
  else {

    let resourceType = event.requestContext.stage
    let resourceId = event.pathParameters.proxy
    let authorizer = event.requestContext.authorizer
    let httpMethod = event.httpMethod.toUpperCase()

    // debug
    console.log('resourceType', JSON.stringify(resourceType, null, 2))
    console.log('resourceId', JSON.stringify(resourceId, null, 2))
    console.log('authorizer', JSON.stringify(authorizer, null, 2))
    console.log('httpMethod', JSON.stringify(httpMethod, null, 2))




    switch (event.httpMethod) {
      // case 'DELETE':
      //   dynamo.deleteItem(JSON.parse(event.body), done);
      //   break;
      // case 'GET':
      //   dynamo.scan({ TableName: event.queryStringParameters.TableName }, done);
      //   break;
      // case 'POST':
      //   dynamo.putItem(JSON.parse(event.body), done);
      //   break;
      // case 'PUT':
      //   dynamo.updateItem(JSON.parse(event.body), done);
      //   break;
      default:
        done({
          message: "hello",
          path: resourceId,
          type: resourceType,
          httpMethod: httpMethod
        });
    }
  }
};