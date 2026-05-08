const { handler } = require("./index");

describe("Lambda handler tests", () => {


  test("GET /health should return 200 with status ok", async () => {
    const event = {
      httpMethod: "GET",
      rawPath: "/health",
      requestContext: { requestId: "test-request-id" }
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
    expect(response.headers["Content-Type"]).toBe("application/json");
    expect(JSON.parse(response.body)).toEqual({ status: "ok" });
  });


  test("POST /event should store event and return 201", async () => {
    const event = {
      httpMethod: "POST",
      rawPath: "/event",
      requestContext: { requestId: "test-request-id" },
      body: JSON.stringify({
        type: "USER_CREATED",
        payload: {
          userId: "123",
          name: "test user"
        }
      })
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(201);

    const body = JSON.parse(response.body);

    expect(body.message).toBe("event stored");
    expect(body.event).toHaveProperty("id");
    expect(body.event.type).toBe("USER_CREATED");
    expect(body.event.payload.userId).toBe("123");
  });

  test("POST /event with invalid JSON should return 400", async () => {
    const event = {
      httpMethod: "POST",
      rawPath: "/event",
      body: "invalid-json"
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(400);
    expect(JSON.parse(response.body).error).toBe("Invalid JSON");
  });

  test("POST /event missing fields should return 400", async () => {
    const event = {
      httpMethod: "POST",
      rawPath: "/event",
      body: JSON.stringify({
        type: "INCOMPLETE_EVENT"
        // payload missing
      })
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(400);
    expect(JSON.parse(response.body).error).toMatch(/Missing required fields/);
  });

 
  test("Unknown route should return 404", async () => {
    const event = {
      httpMethod: "GET",
      rawPath: "/unknown"
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(404);
    expect(JSON.parse(response.body).error).toBe("Not Found");
  });

});