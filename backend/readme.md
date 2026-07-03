# Employee Attendance & Live Tracking Backend API Documentation

## Project Overview

This module provides:

* JWT Protected APIs
* Employee Check-In
* Live GPS Tracking
* Distance Calculation
* Attendance Management
* Check-Out
* Admin Live Tracking
* Attendance History
* Google Map Integration Ready

---

# Authentication

All APIs require JWT authentication.

### Header

```http
Authorization: Bearer <JWT_TOKEN>
```

---

# 1. Check In

## API

```
POST /api/tracking/start
```

## Description

Employee starts the working day.

During check-in the backend automatically:

* Validates JWT
* Validates GPS
* Validates Selfie
* Uploads selfie to Cloudinary
* Reverse geocodes location using TomTom
* Creates today's Attendance
* Creates/Updates Tracking record
* Marks user Online

---

## Request Type

```
multipart/form-data
```

### Body

| Field     | Type   | Required |
| --------- | ------ | -------- |
| photo     | File   | Yes      |
| latitude  | Number | Yes      |
| longitude | Number | Yes      |
| accuracy  | Number | No       |
| speed     | Number | No       |
| heading   | Number | No       |

---

## Success Response

**200 OK**

```json
{
  "success": true,
  "message": "Check In Successful",
  "attendance": {},
  "tracking": {}
}
```

---

## Possible Errors

### 400 Bad Request

```json
{
  "success": false,
  "message": "Selfie is required."
}
```

---

```json
{
  "success": false,
  "message": "Latitude and Longitude are required."
}
```

---

```json
{
  "success": false,
  "message": "GPS accuracy is too low."
}
```

---

### 401 Unauthorized

```json
{
  "message": "Invalid token"
}
```

---

### 409 Conflict

```json
{
  "success": false,
  "message": "Already checked in."
}
```

---

### 500 Internal Server Error

```json
{
  "success": false,
  "message": "Internal Server Error"
}
```

---

# Backend Operations

✔ Upload Selfie

✔ Reverse Geocode

✔ Create Attendance

✔ Create Tracking

✔ Save GPS

✔ Save Address

✔ Save Check-In Time

✔ Mark Online

---

# 2. Update Live Location

## API

```
PUT /api/tracking/update
```

---

## Description

Called every few seconds while the employee is checked in.

Backend automatically:

* Validates GPS
* Ignores poor accuracy
* Calculates travelled distance
* Updates Attendance
* Updates Tracking
* Updates Last Seen
* Updates Address (when required)

---

## Request

```json
{
  "latitude":26.121,
  "longitude":91.701,
  "accuracy":5,
  "speed":12,
  "heading":160
}
```

---

## Success

**200 OK**

```json
{
  "success": true,
  "message": "Location updated",
  "totalDistanceKm": 2.35,
  "data": {}
}
```

---

## Errors

### 400

```json
{
  "success": false,
  "message": "Latitude and longitude are required."
}
```

---

```json
{
  "success": false,
  "message": "GPS accuracy is too low."
}
```

---

### 404

```json
{
  "success": false,
  "message": "Tracking session not found. Please check in first."
}
```

---

```json
{
  "success": false,
  "message": "Attendance record not found."
}
```

---

### 500

```json
{
  "success": false,
  "message": "Internal Server Error"
}
```

---

# Backend Operations

✔ Calculate Distance

✔ Ignore GPS Noise

✔ Update Current Location

✔ Update Total Distance

✔ Update Last Seen

✔ Update Tracking

✔ Update Attendance

---

# 3. Check Out

## API

```
POST /api/tracking/stop
```

---

## Description

Ends employee working session.

Backend automatically:

* Saves checkout GPS
* Reverse geocodes location
* Calculates working hours
* Calculates working minutes
* Marks Attendance Present
* Marks Tracking Offline

---

## Request

```json
{
    "latitude":26.123,
    "longitude":91.706
}
```

---

## Success

```json
{
    "success":true,
    "message":"Checked out successfully",
    "workingMinutes":540,
    "workingHours":"9h 0m",
    "totalDistanceKm":21.32
}
```

---

## Errors

### 400

```json
{
    "success":false,
    "message":"Latitude and longitude are required."
}
```

---

### 404

```json
{
    "success":false,
    "message":"No active tracking session found."
}
```

---

```json
{
    "success":false,
    "message":"Attendance record not found."
}
```

---

### 500

```json
{
    "success":false,
    "message":"Internal Server Error"
}
```

---

# Backend Operations

✔ Save Checkout

✔ Save Checkout GPS

✔ Save Checkout Address

✔ Calculate Working Hours

✔ Mark Attendance Present

✔ Mark Tracking Offline

---

# 4. Current User Status

## API

```
GET /api/tracking/status
```

---

## Description

Returns current authenticated user's tracking status.

---

## Success

```json
{
    "success":true,
    "status":"Online",
    "data":{}
}
```

or

```json
{
    "success":true,
    "status":"Offline",
    "data":null
}
```

---

## Errors

### 401 Unauthorized

```json
{
    "message":"Invalid token"
}
```

---

### 500 Internal Server Error

```json
{
    "success":false,
    "message":"Internal Server Error"
}
```

---

# 5. Live Users (Admin)

## API

```
GET /api/tracking/live
```

---

## Description

Returns all employees currently online.

Admin Dashboard uses this API.

---

## Success

```json
{
    "success":true,
    "total":5,
    "data":[]
}
```

---

## Errors

### 401 Unauthorized

```json
{
    "message":"Invalid token"
}
```

---

### 403 Forbidden

```json
{
    "message":"Access denied"
}
```

---

### 500 Internal Server Error

```json
{
    "success":false,
    "message":"Internal Server Error"
}
```

---

# 6. Today's Attendance

## API

```
GET /api/attendance/today
```

---

## Description

Returns today's attendance of the authenticated employee.

---

## Success

Checked In

```json
{
    "success":true,
    "checkedIn":true,
    "data":{}
}
```

Not Checked In

```json
{
    "success":true,
    "checkedIn":false,
    "data":null
}
```

---

## Errors

### 401 Unauthorized

```json
{
    "message":"Invalid token"
}
```

---

### 500 Internal Server Error

```json
{
    "success":false,
    "message":"Internal Server Error"
}
```

---

# 7. Attendance History

## API

```
GET /api/attendance/history
```

---

## Description

Returns complete attendance history of logged-in employee.

---

## Success

```json
{
    "success":true,
    "total":35,
    "data":[]
}
```

---

## Errors

401 Unauthorized

500 Internal Server Error

---

# 8. Admin Attendance

## API

```
GET /api/attendance/all
```

---

## Description

Returns attendance records of all employees.

Used in Admin Dashboard.

---

## Success

```json
{
    "success":true,
    "total":250,
    "data":[]
}
```

---

## Errors

401 Unauthorized

403 Forbidden

500 Internal Server Error

---

# Database Collections

## Tracking Collection

Stores:

* Current Latitude
* Current Longitude
* Accuracy
* Speed
* Heading
* Place
* City
* State
* Country
* Total Distance
* Last Seen
* Online/Offline Status
* Attendance Reference

---

## Attendance Collection

Stores:

* Employee
* Attendance Date
* Check-In
* Check-Out
* Selfie URL
* Working Minutes
* Total Distance
* Status
* Last Latitude
* Last Longitude

---

# External Services

* JWT Authentication
* Cloudinary (Selfie Upload)
* TomTom Reverse Geocoding
* MongoDB Atlas

---

# HTTP Status Codes Used

| Status Code | Meaning                             |
| ----------- | ----------------------------------- |
| 200         | Request successful                  |
| 400         | Invalid request / validation failed |
| 401         | Authentication failed               |
| 403         | Permission denied                   |
| 404         | Resource not found                  |
| 409         | Duplicate check-in                  |
| 500         | Internal server error               |

---

# Current Module Status

* JWT Authentication: ✅
* Attendance System: ✅
* Live Tracking: ✅
* Check-In with Selfie: ✅
* Check-Out: ✅
* Distance Calculation: ✅
* Working Hours Calculation: ✅
* Reverse Geocoding: ✅
* Cloudinary Integration: ✅
* Admin Dashboard APIs: ✅
* Google Maps Ready: ✅
* Production Ready: ✅
