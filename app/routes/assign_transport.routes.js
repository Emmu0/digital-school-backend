// routes.js

const express = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
//const permissions = require("../constants/permissions.js");
const assignTransport = require("../models/assign_transport.model.js");
const fareMaster = require("../models/faremaster.model.js")

module.exports = app => {
    var router = require("express").Router();

    // Fetch Assign Transport Record by ID
    router.get("/:id?", fetchUser, [], async (req, res) => {
        try {
            assignTransport.init(req.userinfo.tenantcode);
            const result = await assignTransport.fetchRecordById(req?.params?.id);

            if (result) {
                return res.status(200).json(result);
            } else {
                return res.status(400).json({ success: false, message: "No record found" });
            }
        } catch (error) {
            return res.status(500).json({ success: false, message: error.message });
        }
    });


    // Add Assign Transport Record
    router.post("/", fetchUser, [], async (req, res) => {
        
        const newRecord = req.body;
        let fare_id = null;
        let fare_amount = 0;

        if (newRecord?.distance) {
            fareMaster.init(req.userinfo.tenantcode);
            const fareMasterResult = await fareMaster.getAllFares();
            if (fareMasterResult) {
                fareMasterResult.map((res) => {
                    if (newRecord.distance >= res.fromdistance && newRecord.distance <= res.todistance) {
                        fare_id = res.id;
                        fare_amount = res.fare;
                    }
                })


            }
        }

        const arr = { ...newRecord, fare_id: fare_id, fare_amount: fare_amount };


        assignTransport.init(req.userinfo.tenantcode);
        const result = await assignTransport.addRecord(arr);
        if (result) {
            return res.status(200).json({ "success": true, "result": result });
        } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
    });

    // Update Assign Transport Record
    router.put("/:id", fetchUser, [], async (req, res) => {
        
        const id = req.params.id;
        const newRecord = req.body;
        assignTransport.init(req.userinfo.tenantcode);
        const result = await assignTransport.updateRecordById(id, newRecord);
        if (result) {
            return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
    });

    // Delete Assign Transport Record by ID
    router.delete("/:id", fetchUser, [], async (req, res) => {
        
        assignTransport.init(req.userinfo.tenantcode);
        const result = await assignTransport.deleteRecord(req.params.id);
        if (!result)
            return res.status(200).json({
                "success": false,
                "message": "This Record has reference in another table."
            });

        res.status(200).json({
            "success": true,
            "message": "Successfully Deleted"
        });
    });

    app.use('/api/assigntransport', router);
};
