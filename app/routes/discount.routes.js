const express = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const discountRecord = require("../models/discount.model.js");
//const permissions = require("../constants/permissions.js");
const { body, validationResult } = require("express-validator");

module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();
  

// Add Discount Record
router.post("/", fetchUser, [], async (req, res) => {
    
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    discountRecord.init(req.userinfo.tenantcode);
    let duplicate = await discountRecord.duplicateRecord(null, req.body);

    if (!duplicate) {
        const result = await discountRecord.addRecord(req.body, req.userinfo.id);
        if (result) {
            return res.status(200).json({ "success": true, "result": result });
        } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
    } else {
        return res.status(200).json({ "success": false, "message": "Record is already exist!" });
    }
});

// Fetch All Discount Records
router.get("/", fetchUser, async (req, res) => {
    // Check permissions
    
    
    discountRecord.init(req.userinfo.tenantcode);
    const result = await discountRecord.fetchAllRecords();
    if (result) {
        res.status(200).json(result);
    } else {
        res.status(400).json({ errors: "No data" });
    }
});

// Fetch Discount Record by ID
router.get("/:id", fetchUser, async (req, res) => {
    try {
        // Check permissions
        
        
        discountRecord.init(req.userinfo.tenantcode);
        let result = await discountRecord.fetchRecordById(req.params.id);
        if (result) {
            return res.status(200).json(result);
        } else {
            return res.status(200).json({ "success": false, "message": "No record found" });
        }
    } catch (error) {
        return res.status(400).json({ "success": false, "message": error.message });
    }
});

// Update Discount Record
router.put("/:id", fetchUser, async (req, res) => {
    try {
        // Check permissions
        

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        console.log('req.body while put -->', req.body);
        const newdata = req.body;
        delete newdata.id;
        delete newdata.session;
        delete newdata.headname;

        console.log('newdata-->',newdata);

        discountRecord.init(req.userinfo.tenantcode);
        let result = await discountRecord.fetchRecordById(req.params.id);
        if (result) {
            discountRecord.init(req.userinfo.tenantcode);
            let duplicate = await discountRecord.duplicateRecord(req.params.id, newdata);
            console.log('duplicate-->',duplicate);
            if (!duplicate) {
                console.log('im in side duplicate')
            //  discountRecord.init(req.userinfo.tenantcode);
              console.log('req.body before after-->', req.body)
                const resultCon = await discountRecord.updateRecordById(req.params.id, newdata, req.userinfo.id);
                console.log('resultCon--->',resultCon);
                if (resultCon) {
                    return res.status(200).json({ "success": true, "message": "Record updated successfully" });
                } else {
                    return res.status(200).json({ "success": false, "message": "Bad Request" });
                }
            } else {
                return res.status(200).json({ "success": false, "message": "Record is already exist!" });
            }

        } else {
            return res.status(200).json({ "success": false, "message": "No record found" });
        }

    } catch (error) {
        res.status(400).json({ errors: error.message });
    }
});

// Delete Discount Record by ID
router.delete("/:id", fetchUser, async (req, res) => {
    // Check permissions
    
    
    discountRecord.init(req.userinfo.tenantcode);
    const result = await discountRecord.deleteRecord(req.params.id);
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

app.use( '/api/discount', router);
};