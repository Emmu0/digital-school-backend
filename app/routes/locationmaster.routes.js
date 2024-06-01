/**
 * Handles all incoming request for /api/transportation/vehicles endpoint
 * DB table for this public.transport
 * Model used here is transport.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/locationmaster/location
 *              GET     /api/locationmaster/location/:id
 *              POST    /api/locationmaster/location
 *              PUT     /api/locationmaster/location/:id
 *              DELETE  /api/locationmaster/location/:id
 * 
 * @author      Shivam Shrivastava
 * @date        sep, 2023
 * @copyright   www.ibirdsservices.com  
 */
// Import the necessary functions from your locationmaster model
const { createLocation,getLocationById,getAllLocations,updateLocation,deleteLocation,checkDuplicateLocation,init } = require("../models/locationmaster.model.js");
//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");

module.exports = (app) => {
    const { body, validationResult } = require("express-validator");

    var router = require("express").Router();

    // Add a new route for creating a location entry (POST)
    router.post(
        "/location",
        fetchUser,
        [
            body('location', 'Please provide a location').isLength({ min: 1 }),
            body('distance', 'Please provide a valid distance').isNumeric(),
            body('status', 'Please provide a status').isLength({ min: 1 }),
        ],
        async (req, res) => {
           

            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }

            const locationData = req.body;
            const isDuplicate = await checkDuplicateLocation(locationData);
            if (isDuplicate) {
                return res.status(400).json({ errors: "Record already exists." });
            }
            init(req.userinfo.tenantcode);
            const createdLocation = await createLocation(locationData);

            if (!createdLocation) {
                return res.status(400).json({ errors: "Bad Request" });
            }

            return res.status(201).json(createdLocation);
        }
    );

    // Add a route to retrieve all location entries (GET)
    router.get("/location", fetchUser, async (req, res) => {
        try {
           
            init(req.userinfo.tenantcode);
            const allLocations = await getAllLocations();

            if (allLocations) {
                console.log('allLocations => ', allLocations);
                res.status(200).json(allLocations);
            } else {
                res.status(400).json({ errors: "No data" });
            }
        } catch (error) {
            console.error("Error in /locations route:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    // Add a route to retrieve a specific location by ID (GET)
    router.get("/location/:id", fetchUser, async (req, res) => {
        try {
           
            const locationId = req.params.id;
            init(req.userinfo.tenantcode);
            const location = await getLocationById(locationId);

            if (location) {
                return res.status(200).json(location);
            } else {
                return res.status(404).json({ errors: "Location not found" });
            }
        } catch (error) {
            console.error('System Error:', error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    // Add a route to update a specific location by ID (PUT)
    router.put("/location/:id", fetchUser, async (req, res) => {
        try {
         

            const locationId = req.params.id;
            const updatedLocationData = req.body;
            const isDuplicate = await checkDuplicateLocation(updatedLocationData);
            if (isDuplicate) {
                return res.status(400).json({ errors: "Record already exists." });
            }
            init(req.userinfo.tenantcode);
            const updatedLocation = await updateLocation(locationId, updatedLocationData);

            if (updatedLocation) {
                return res.status(200).json(updatedLocation);
            } else {
                return res.status(404).json({ errors: "Location not found" });
            }
        } catch (error) {
            console.error('System Error:', error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });
    //-----------------------------delete-------------------------------
    router.delete("/location/:id", fetchUser, async (req, res) => {
        try {
           

            const locationId = req.params.id;
            init(req.userinfo.tenantcode);
            const deletedLocation = await deleteLocation(locationId);

            if (deletedLocation) {
                return res.status(200).json({ message: "Location deleted successfully" });
            } else {
                return res.status(404).json({ errors: "Location not found" });
            }
        } catch (error) {
            console.error('System Error:', error);
            return res.status(404).json({ errors: "Record has reference in another table.Deletion not allowed." });
        }
    });


    app.use(process.env.BASE_API_URL + '/api/locationmaster', router);
};
