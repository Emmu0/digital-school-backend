/**
 * Handles all incoming requests for /api/transportation/vehicles endpoint
 * DB table for this public.transport
 * Model used here is transport.model.js
 * SUPPORTED API ENDPOINTS
 *   GET     /api/transportation/vehicles
 *   GET     /api/transportation/vehicles/:id
 *   POST    /api/transportation/vehicles
 *   PUT     /api/transportation/vehicles/:id
 *   DELETE  /api/transportation/vehicles/:id
 * @author      Shivam Shrivastava
 * @date        3 oct, 2023
 * @copyright   www.ibirdsservices.com
 */


const { fetchUser } = require("../middleware/fetchuser.js");
//const permissions = require("../constants/permissions.js");
const {
    createTransport,
    updateTransport,
    getAllTransports,
    getTransportById,
    deleteTransport,
    findAllVehicles,
    init,
    CheckDuplicateTransport
} = require("../models/transports.model.js");

module.exports = (app) => {
    const { body, validationResult } = require("express-validator");
    var router = require("express").Router();

    router.post( "/vehicles",fetchUser,[],async (req, res) => {
            
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({success: false, errors: errors.array() });
            }

            const transportData = req.body;

            transportData.driver_id =
                transportData.driver_id === "" ? null : transportData.driver_id;
            transportData.seating_capacity =
                transportData.seating_capacity === ""
                    ? null
                    : transportData.seating_capacity;
            init(req.userinfo.tenantcode);
            const duplicate = await CheckDuplicateTransport(false,transportData);
            if (!duplicate) {
                try {
                    const createdTransport = await createTransport(transportData);

                    if (!createdTransport) {
                        return res.status(500).json({success: false, errors: "Internal Server Error" });
                    }

                    return res.status(201).json({
                        success: true,
                        message: "Transport created successfully",
                        transport: createdTransport,
                    });
                } catch (error) {
                    //   console.error("Error creating transport:", error);
                    return res.status(500).json({ success: false, errors: "Internal Server Error" });
                }
            } else {
                return res
                    .status(200)
                    .json({ success: false, message: "Record already exists." });
            }
        }
    );

    // Add a route to retrieve all transports (GET)
    router.get("/vehicles", fetchUser, async (req, res) => {
        try {            
            console.log('req.userinfo.tenantcode==>', req.userinfo.tenantcode)
            init(req.userinfo.tenantcode);
            const allTransports = await getAllTransports();

            if (allTransports) {
                res.status(200).json(allTransports);
            } else {
                res.status(400).json({ errors: "No data" });
            }
        } catch (error) {
            console.error("Error in /vehicles route:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    // Add a route to retrieve a specific transport by ID (GET)
    router.get("/vehicles/:id", fetchUser, async (req, res) => {
        try {
            const transportId = req.params.id;
            init(req.userinfo.tenantcode);
            const transport = await getTransportById(transportId);

            if (transport) {
                return res.status(200).json(transport);
            } else {
                return res.status(404).json({ errors: "Transport not found" });
            }
        } catch (error) {
            console.error("System Error:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    router.put(
        "/vehicles/:id", fetchUser, [], async (req, res) => {
            try {
               
                const errors = validationResult(req);
                if (!errors.isEmpty()) {
                    return res.status(400).json({ success: false, errors: errors.array() });
                }

                const transportId = req.params.id;
                const updatedTransportData = req.body;
                console.log(';;;;;;;;;;;', updatedTransportData)

                updatedTransportData.driver_id = updatedTransportData.driver_id === "" ? null : updatedTransportData.driver_id;
                updatedTransportData.seating_capacity = updatedTransportData.seating_capacity === "" ? null : updatedTransportData.seating_capacity;
                updatedTransportData.end_point = updatedTransportData.end_point === "" ? null : updatedTransportData.end_point;
                
                init(req.userinfo.tenantcode);
                const duplicate = await CheckDuplicateTransport(true,updatedTransportData)
                
                if (!duplicate) {
                    const updatedTransport = await updateTransport(
                        transportId,
                        updatedTransportData
                    );

                    if (updatedTransport) {
                        return res.status(200).json({
                            success: true,
                            message: "Transport updated successfully",
                            transport: updatedTransport,
                        });
                    } else {
                        return res.status(404).json({ success: false, errors: "Transport not found" });
                    }
                } else {
                    return res.status(200).json({ "success": false, "message": "Record already exists." });

                }
            } catch (error) {
                console.error("System Error:", error);
                return res.status(500).json({ success: false, errors: "Internal Server Error" });
            }
        }
    );

    // Add a route to delete a specific transport by ID (DELETE)
    router.delete("/vehicles/:id", fetchUser, async (req, res) => {
        try {           
            const transportId = req.params.id;
            init(req.userinfo.tenantcode);
            const deletedTransport = await deleteTransport(transportId);

            if (deletedTransport) {
                return res.status(200).json({
                    message: "Transport deleted successfully",
                });
            } else {
                return res.status(404).json({ errors: "Transport not found" });
            }
        } catch (error) {
            console.error("System Error:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });
    router.get("/vehiclesRte", fetchUser, async (req, res) => {
    
        init(req.userinfo.tenantcode);
        const findAllVehicle = await findAllVehicles();
        if (findAllVehicle) {
            console.log('findAllVehicle => ', findAllVehicle)
            res.status(200).json(findAllVehicle);
        } else {
            res.status(400).json({ errors: "No data" });
        }
    });
    app.use(process.env.BASE_API_URL + "/api/transportation", router);


};
