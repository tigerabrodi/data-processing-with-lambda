exports.handler = async (event) => {
  // Just logging the event for now
  // In a real app, you would do something with the data
  console.log("Received event:", JSON.stringify(event, null, 2));
};
