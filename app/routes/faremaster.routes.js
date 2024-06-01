/**
 * Handles all incoming request for /api/transportation/vehicles endpoint
 * DB table for this public.transport
 * Model used here is transport.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/faremaster/fare
 *              GET     /api/faremaster/fare/:id
 *              POST    /api/faremaster/fare
 *              PUT     /api/faremaster/fare/:id
 *              DELETE  /api/faremaster/fare/:id
 * 
 * @author      Shivam Shrivastava
 * @date        sep, 2023
 * @copyright   www.ibirdsservices.com  
 */
// Import the insertFare function from your model
const { insertFare, getFareById, getAllFares, deleteFare, updateFare, checkDuplicateFare, init } = require("../models/faremaster.model.js"); // Import necessary functions
const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");


module.exports = app => {
    const { body, validationResult } = require("express-validator");

    var router = require("express").Router();


    router.post("/fare", fetchUser, [
        body('Fare', 'Please provide fare').isNumeric(),
        body('FromDistance', 'Please provide FromDistance').isNumeric(),
        body('ToDistance', 'Please provide ToDistance').isNumeric(),
        body('Status', 'Please provide Status').isLength({ min: 1 }),
    ],
        async (req, res) => {
            // Check permissions

            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }

            const fareData = req.body;
            const isDuplicate = await checkDuplicateFare(fareData);
            if (isDuplicate) {
                return res.status(400).json({ errors: "Record already exists." });
            }
            init(req.userinfo.tenantcode);
            const insertedFare = await insertFare(fareData);

            if (!insertedFare) {
                return res.status(400).json({ errors: "Bad Request" });
            }

            // Send success message
            return res.status(201).json({ message: "Fare created successfully", fare: insertedFare });
        });

    // Add a route to retrieve all fare data (GET)
    router.get("/fare", fetchUser, async (req, res) => {
        try {
            // Check permissions


            init(req.userinfo.tenantcode);
            const allFares = await getAllFares();

            if (allFares) {
                console.log('allFares => ', allFares);
                res.status(200).json(allFares);
            } else {
                res.status(400).json({ errors: "No data" });
            }
        } catch (error) {
            console.error("Error in /fare route:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });


    // Add a route to retrieve a specific fare by ID (GET)
    router.get("/fare/:id", fetchUser, async (req, res) => {
        try {
            // Check permissions


            const fareId = req.params.id;
            init(req.userinfo.tenantcode);
            const fare = await getFareById(fareId); // Implement this function in your model

            if (fare) {
                return res.status(200).json(fare);
            } else {
                return res.status(404).json({ errors: "Fare not found" });
            }
        } catch (error) {
            console.error('System Error:', error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });
    //------------------------delete Fare---------------------

    router.delete("/fare/:id", fetchUser, async (req, res) => {
        try {
            // Check permissions


            const fareId = req.params.id;
            init(req.userinfo.tenantcode);
            const deletedFare = await deleteFare(fareId);

            if (deletedFare) {
                return res.status(200).json({ message: "fare deleted successfully" });
            } else {
                return res.status(404).json({ errors: "fare not found" });
            }
        } catch (error) {
            console.error('System Error:', error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    // Add a route to update a specific fare by ID (PUT)
    router.put("/fare/:id", fetchUser, [
        body('Fare', 'Please provide fare').isNumeric(),
        body('FromDistance', 'Please provide FromDistance').isNumeric(),
        body('ToDistance', 'Please provide ToDistance').isNumeric(),
        body('Status', 'Please provide Status').isLength({ min: 1 }),
    ], async (req, res) => {
        try {
            // Check permissions


            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }

            const fareId = req.params.id;
            const updatedFareData = req.body;
            const isDuplicate = await checkDuplicateFare(updatedFareData);
            if (isDuplicate) {
                return res.status(400).json({ errors: "Record already exists." });
            }
            // Implement the updateFare function in your model to handle the update
            init(req.userinfo.tenantcode);
            const updatedFare = await updateFare(fareId, updatedFareData);

            if (updatedFare) {
                return res.status(200).json({ message: "Fare updated successfully", fare: updatedFare });
            } else {
                return res.status(404).json({ errors: "Fare not found" });
            }
        } catch (error) {
            console.error('System Error:', error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    app.use(process.env.BASE_API_URL + '/api/faremaster', router);
};
