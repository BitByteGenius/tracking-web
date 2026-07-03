import axios from "axios";

export const reverseGeocode = async (latitude, longitude) => {
  try {
    const response = await axios.get(
      `https://api.tomtom.com/search/2/reverseGeocode/${latitude},${longitude}.json`,
      {
        params: {
          key: process.env.TOMTOM_API_KEY,
        },
      }
    );

    const address = response.data?.addresses?.[0]?.address;

    if (!address) {
      return {
        place: "",
        city: "",
        state: "",
        country: "",
      };
    }

    return {
      place: address.streetName || "",
      city: address.municipality || "",
      state: address.countrySubdivision || "",
      country: address.country || "",
    };

  } catch (error) {

    console.error("Reverse Geocoding Error:", error.message);

    return {
      place: "",
      city: "",
      state: "",
      country: "",
    };
  }
};