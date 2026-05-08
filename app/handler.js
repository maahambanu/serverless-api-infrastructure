const eventsStore = []; // in-memory store for simplicity (replace with DynamoDB later)

exports.handler = async (event) => {
  const method = event.httpMethod;
  const path = event.rawPath;

  const log = {
    level: "INFO",
    message: "Request received",
    requestId: event.requestContext?.requestId,
    method,
    path,
    timestamp: new Date().toISOString()
  };

  console.log(JSON.stringify(log));

  // GET /health
  if (method === "GET" && path === "/health") {
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status: "ok" })
    };
  }

  // POST /event
  if (method === "POST" && path === "/event") {
    let body;

    try {
      body = JSON.parse(event.body || "{}");
    } catch (err) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Invalid JSON" })
      };
    }

    if (!body.type || !body.payload) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Missing required fields: type, payload" })
      };
    }

    const eventRecord = {
      id: Date.now().toString(),
      type: body.type,
      payload: body.payload,
      timestamp: new Date().toISOString()
    };

    eventsStore.push(eventRecord);

    return {
      statusCode: 201,
      body: JSON.stringify({ message: "event stored", event: eventRecord })
    };
  }

  return {
    statusCode: 404,
    body: JSON.stringify({ error: "Not Found" })
  };
};