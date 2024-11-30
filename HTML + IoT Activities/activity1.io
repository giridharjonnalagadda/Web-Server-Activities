# How does the ESP32 web server dynamically read and display soil moisture levels on a webpage, and what changes can be made to update the data in real-time with refreshing the page?



#include <WiFi.h>
#include <WebServer.h>

// Replace with your Wi-Fi credentials
const char* ssid = "Act";
const char* password = "Madhumakeskilled";

// Create a web server object on port 80
WebServer server(80);

// Define analog pin for the soil moisture sensor
const int sensorPin = 34; // Use GPIO 34 or any other ADC pin

void setup() {
  Serial.begin(115200);
  
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  
  // Define the web server route
  server.on("/", []() {
    int moistureValue = analogRead(sensorPin); // Read soil moisture sensor value
    float percentage = map(moistureValue, 0, 4095, 0, 100); // Convert to percentage
    
    // Create a simple HTML page
    String html = "<html><body>";
    html += "<h1>Soil Moisture Sensor</h1>";
    html += "<p>Moisture Value (Raw): " + String(moistureValue) + "</p>";
    html += "<p>Soil Moisture (%): " + String(percentage) + "</p>";
    html += "</body></html>";
    
    server.send(200, "text/html", html); // Send the HTML page
  });
  
  // Start the server
  server.begin();
}

void loop() {
  server.handleClient(); // Handle client requests
}