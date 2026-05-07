exports.handler = async (event) => {

  const log = {
    level: "INFO",
    message: "Health endpoint called",
    requestId: event.requestContext?.requestId,
    path: event.rawPath,
    timestamp: new Date().toISOString()
  };

  console.log(JSON.stringify(log));

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      status: "ok"
    })
  };
};