db = db.getSiblingDB('car_retail'); // Tạo DB mới
db.createUser({
    user: "dongnt",
    pwd: "dongcopper80",
    roles: [{ role: "readWrite", db: "car_retail" }]
});
db.createCollection("cars", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name"],
            properties: {
                name: { bsonType: "string", description: "must be UTF-8 string" }
            }
        }
    }
});
print("✅ MongoDB init script executed successfully!");