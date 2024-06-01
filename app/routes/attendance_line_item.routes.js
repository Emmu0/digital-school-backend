/**
 * @author: Abdul Pathan
 */

const e = require("express");

const { fetchUser } = require("../middleware/fetchuser.js");
const attendanceLineItemModel = require("../models/attendance_line_item.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();

    //Created By Pooja : For Mobile App : 23-04-2024
    router.get("/student_id/:student_id/month/:month", fetchUser, async (req, res) => {    //Check permissions

        
        attendanceLineItemModel.init(req.userinfo.tenantcode);
        let result = await attendanceLineItemModel.getAttendanceByStudentIdAndMonth(req.params.student_id, req.params.month); //get Records
        if (result) {
            return res.status(200).json({ "success": true, "result": result });
        } else {
            res.status(200).json({ "success": false, "message": "No Record Found!" });
        }
    });

    router.get("/:?", fetchUser, async (req, res) => {
        try { //Check permissions
            

            const classId = req.query.class_id;
            const sectionId = req.query.section_id;
            const date = req.query.date;

            attendanceLineItemModel.init(req.userinfo.tenantcode);
            let result = await attendanceLineItemModel.getAllRecords(classId, sectionId, date);

            if (result) {
                res.status(200).json({ success: true, "records": result });
            } else {
                res.status(200).json({ success: false, "message": "No Record Found!" });
            }
        } catch (error) {
            return res.status(200).json({ success: false, message: error });
        }
    });

    /* Get attendance */
    router.get("/student_id/:student_id/month/:month", fetchUser, async (req, res) => {    //Check permissions

        
        attendanceLineItemModel.init(req.userinfo.tenantcode);
        let result = await attendanceLineItemModel.getAttendanceByStudentIdAndMonth(req.params.student_id, req.params.month); //get Records
        if (result) {
            return res.status(200).json({ "success": true, "result": result });
        } else {
            res.status(200).json({ "success": false, "message": "No Record Found!" });
        }
    });

    //add Record
    router.post("/", fetchUser, [
        body('attendance_id', 'Please enter attendance id').isLength({ min: 1 }),

    ],

        async (req, res) => {    //Check permissions
            
            const errors = validationResult(req);

            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }
            attendanceLineItemModel.init(req.userinfo.tenantcode);
            let duplicate = await attendanceLineItemModel.duplicateRecord(null, req.body);//check duplicate Record

            if (!duplicate) {
                const result = await attendanceLineItemModel.addRecord(req.body, req.userinfo.id);//add Record
                if (result) {
                    return res.status(200).json({ "success": true, "recordId": result });
                }
                else {
                    return res.status(200).json({ "success": false, "message": "Bad Request" });
                }
            }
            else {
                return res.status(200).json({ "success": false, "id": duplicate.id, "message": "Record already exists." });
            }
        });



    //update Record
    router.put("/:id", fetchUser, async (req, res) => {//Check permissions
        try {

            


            const { attendance_id, status } = req.body;
            const errors = [];
            const atLineItemRecord = {};

            if (req.body.hasOwnProperty("attendance_id")) { atLineItemRecord.attendance_id = attendance_id };
            if (req.body.hasOwnProperty("status")) { atLineItemRecord.status = status };


            if (errors.length !== 0) {
                return res.status(400).json({ errors: errors });
            }
            attendanceLineItemModel.init(req.userinfo.tenantcode);
            let result = await attendanceLineItemModel.getRecordById(req.params.id);

            if (result) {

                let duplicate = await attendanceLineItemModel.duplicateRecord(req.params.id, atLineItemRecord);//duplicate Record check

                if (!duplicate) {

                    let responce = await attendanceLineItemModel.updateRecordById(req.params.id, atLineItemRecord, req.userinfo.id);

                    if (responce) {
                        return res.status(200).json({ "success": true, "record": responce });
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


    app.use(process.env.BASE_API_URL + '/api/attendance_line_item', router);
}
