/**
 * @author: Abdul Pathan
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const attendanceMasterModel = require("../models/attendance_master.model.js");
//const permissions = require("../constants/permissions.js");


module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();


    //fetch All Records
    router.get("/", fetchUser, async (req, res) => {    //Check permissions
        
        attendanceMasterModel.init(req.userinfo.tenantcode);
        const result = await attendanceMasterModel.getAllRecords(); //get Records
        if (result) {
            return res.status(200).json(result);
        } else {
            res.status(200).json({ "message": "No Record Found!" });
        }
    });

    //fetch RecordById
    router.get("/:id", fetchUser, async (req, res) => {    //Check permissions
        try {
            
            attendanceMasterModel.init(req.userinfo.tenantcode);
            let result = await attendanceMasterModel.getRecordById(req.params.id);//get Record By Id
            if (result) {
                return res.status(200).json(result);
            } else {
                res.status(200).json({ "message": "No Record Found!" });
            }
        } catch (error) {
            return res.status(400).json({ "success": false, "message": error });
        }
    });

    //add Record
    router.post("/", fetchUser, [
        body('class_id', 'Please enter class name').isLength({ min: 1 }),
        // body('status', 'Please enter status').isLength({ min: 1 }),
    ],

        async (req, res) => {    //Check permissions
            
            const errors = validationResult(req);

            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }
            attendanceMasterModel.init(req.userinfo.tenantcode);
            let duplicate = await attendanceMasterModel.duplicateRecord(null, req.body);//check duplicate Record
            if (!duplicate) {
                const result = await attendanceMasterModel.addRecord(req.body, req.userinfo.id);//add Record
                if (result) {
                    return res.status(200).json({ "success": true, "record": result });
                }
                else {
                    return res.status(200).json({ "success": false, "message": "Bad Request" });
                }
            }
            else {
                return res.status(200).json({ "success": false, "message": "Record already exists." });
            }
        });


    //update Record
    router.put("/:id", fetchUser, async (req, res) => {//Check permissions
        try {

            

            const { class_id, section_id, total_lectures, type, month, year } = req.body;
            const errors = [];
            const atMasterRecord = {};

            if (req.body.hasOwnProperty("class_id")) { atMasterRecord.class_id = class_id };
            if (req.body.hasOwnProperty("section_id")) { atMasterRecord.section_id = section_id };

            if (req.body.hasOwnProperty("total_lectures")) { atMasterRecord.total_lectures = total_lectures };
            if (req.body.hasOwnProperty("type")) { atMasterRecord.type = type };
            if (req.body.hasOwnProperty("month")) { atMasterRecord.month = month };
            if (req.body.hasOwnProperty("year")) { atMasterRecord.year = year };

            if (errors.length !== 0) {
                return res.status(400).json({ errors: errors });
            }
            attendanceMasterModel.init(req.userinfo.tenantcode);
            let result = await attendanceMasterModel.getRecordById(req.params.id);

            if (result) {
                let duplicate = await attendanceMasterModel.duplicateRecord(req.params.id, atMasterRecord);//duplicate Record check
                if (!duplicate) {

                    let responce = await attendanceMasterModel.updateRecordById(req.params.id, atMasterRecord, req.userinfo.id);

                    if (responce) {
                        return res.status(200).json({ "success": true, "message": "Record updated successfully" });
                    } else {
                        return res.status(200).json({ "success": false, "message": "Bad Request" });
                    }
                } else {
                    return res.status(200).json({ "success": false, "message": "Record already exists." });
                }
            } else {
                return res.status(200).json({ "success": false, "message": "No record found" });
            }
        } catch (error) {

            return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
    });

    app.use(process.env.BASE_API_URL + '/api/attendance_master', router);
}
