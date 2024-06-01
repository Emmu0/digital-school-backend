/**
 * Handles all incoming requests for /api/transportation/vehicles endpoint
 * DB table for this public.transport
 * Model used here is transport.model.js
 * SUPPORTED API ENDPOINTS
 *   POST     /api/route/createroute
 *   GET     /api/route/getroute
 *   GET    /api/route/routebyid/:id
 *   PUT     /api/route/routeupdate/:id
 *   DELETE  /api/route/deleteroute/:id
 * @author      Shivam Shrivastava
 * @date        8 Nov, 2023
 * @copyright   www.ibirdsservices.com
 */


const { fetchUser } = require("../middleware/fetchuser.js");
//const permissions = require("../constants/permissions.js");
const {
    createRoute,
    getAllRoutes,
    getRouteById,
    updateRoute,
    deleteRoute,
    isDuplicateRoute,
    init
} = require("../models/route.model.js");



module.exports = (app) => {
    const { body, validationResult } = require("express-validator");
    var router = require("express").Router();


    router.post(
        "/createroute",
        fetchUser,
        [],
        async (req, res) => {
            

            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }

            const routeData = req.body;

            console.log("req------->", routeData);
            try {                
                const isDuplicate = await isDuplicateRoute(
                    routeData.locationid,
                    routeData.transportid,
                    routeData.order_no
                );

                if (isDuplicate) {
                    return res.status(400).json({ errors: "Record already exists." });
                }
                init(req.userinfo.tenantcode);
                const createdRoute = await createRoute(routeData);
                console.log("createdRoute:", createdRoute); // Fix this line

                if (!createdRoute) {
                    return res.status(500).json({ errors: "Internal Server Error" });
                }

                return res.status(201).json({
                    message: "route created successfully",
                    route: createdRoute,
                });

            } catch (error) {
                console.error("Error creating route:", error);
                return res.status(500).json({ errors: "Internal Server Error" });
            }
        }
    );
    // Add a route to retrieve all transports (GET)
    router.get("/getroute", fetchUser, async (req, res) => {
        try {
           
            init(req.userinfo.tenantcode);   
            const allRoute = await getAllRoutes();
            console.log('allRoute allRoute => ', allRoute)

            if (allRoute) {
                res.status(200).json(allRoute);
            } else {
                res.status(400).json({ errors: "No data" });
            }
        } catch (error) {
            // console.error("Error in / route:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    // Add a route to retrieve a specific transport by ID (GET)
    router.get("/routebyid/:id", fetchUser, async (req, res) => {
        try {
           

            const routeId = req.params.id;
            init(req.userinfo.tenantcode);
            const routes = await getRouteById(routeId);

            if (routes) {
                return res.status(200).json(routes);
            } else {
                return res.status(404).json({ errors: "route not found" });
            }
        } catch (error) {
            console.error("System Error:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });


    router.put(
        "/routeupdate/:id",
        fetchUser,
        [],
        async (req, res) => {
            try {
               

                const errors = validationResult(req);
                if (!errors.isEmpty()) {
                    return res.status(400).json({ errors: errors.array() });
                }

                const routeId = req.params.id;
                const updatedRouteData = req.body;
                const isDuplicate = await isDuplicateRoute(
                    updatedRouteData.locationid,
                    updatedRouteData.transportid,
                    updatedRouteData.order_no,
                    routeId
                );
                console.log('========>',isDuplicate);

                if (isDuplicate) {
                    return res.status(400).json({ errors: "Record already exists." });
                }
                console.log('updatedTransportData ==> ', updatedRouteData);
                init(req.userinfo.tenantcode);
                const updatedRoute = await updateRoute(
                    routeId,
                    updatedRouteData
                );

                if (updatedRoute) {
                    return res.status(200).json({
                        message: "route updated successfully",
                        route: updatedRoute,
                    });
                } else {
                    return res.status(404).json({ errors: "route not found" });
                }
            } catch (error) {
                console.error("System Error:", error);
                return res.status(500).json({ errors: "Internal Server Error" });
            }
        }
    );





    // Add a route to delete a specific transport by ID (DELETE)
    router.delete("/deleteroute/:id", fetchUser, async (req, res) => {
        try {
           

            const routeId = req.params.id;
            init(req.userinfo.tenantcode);
            const deletedRoute = await deleteRoute(routeId);

            if (deletedRoute) {
                return res.status(200).json({
                    message: "Route deleted successfully",
                });
            } else {
                return res.status(404).json({ errors: "Transport not found" });
            }
        } catch (error) {
            console.error("System Error:", error);
            return res.status(500).json({ errors: "Internal Server Error" });
        }
    });

    app.use(process.env.BASE_API_URL + "/api/route", router);


};