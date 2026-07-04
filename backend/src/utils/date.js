// Returns today's date in YYYY-MM-DD format (India Time)

export const getAttendanceDate = () => {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
  }).format(new Date());
};

// Returns current Date object

export const getCurrentDateTime = () => {
  return new Date();
};