/**
 * @author: Abdul Pathan
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const attendanceModel = require("../models/attendance.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();

    router.get("/attInfo/:month?/:year?", fetchUser, async (req, res) => {    //Check permissions


        attendanceModel.init(req.userinfo.tenantcode);
        const result = await attendanceModel.getRecordsByMonthAndYear(req.params.month, req.params.year);
        if (result) {
            return res.status(200).json({ "success": true, "result": result });
        } else {
            res.status(200).json({ "success": false, "message": "No Record Found!" });
        }
    });
    //
    router.get("/student_id/:student_id", fetchUser, async (req, res) => {    //Check permissions
        try {


            attendanceModel.init(req.userinfo.tenantcode);
            let result = await attendanceModel.getAttendanceByStudentId(req.params.student_id);//get Record By Id

            if (result) {
                return res.status(200).json(result);
            } else {
                res.status(400).json({ errors: "No Record Found!" });
            }
        } catch (error) {
            return res.status(400).json({ "success": false, "message": error });
        }
    });
    //fetch All Records
    router.get("/", fetchUser, async (req, res) => {    //Check permissions


        attendanceModel.init(req.userinfo.tenantcode);
        try {
            const result = await attendanceModel.getAllRecords(); //get Records
            console.log('result&&&=>', result)
            if (result) {
                console.log('ifRES=>', result)
                res.status(200).json(result);

            } else {
                console.log('ElseRES=>', result)

                res.status(200).json({ "success": false, "message": "No Record Found!" });
            }
        } catch (error) {
            res.status(400).json({ "success": false, "message": error });
        }

    });

    //fetch RecordById
    router.get("/:id", fetchUser, async (req, res) => {    //Check permissions
        try {

            attendanceModel.init(req.userinfo.tenantcode);
            let result = await attendanceModel.getRecordById(req.params.id);//get Record By Id
            if (result) {
                return res.status(200).json(result);
            } else {
                res.status(400).json({ errors: "No Record Found!" });
            }
        } catch (error) {
            return res.status(400).json({ "success": false, "message": error });
        }
    });


    //add Record
    router.post("/", fetchUser, [

    ],

        async (req, res) => {    //Check permissions

            const errors = validationResult(req);

            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }

            attendanceModel.init(req.userinfo.tenantcode);
            let duplicate = await attendanceModel.duplicateRecord(req.body);//check duplicate Record

            if (!duplicate) {
                const result = await attendanceModel.addRecord(req.body, req.userinfo.id);//add Record
                if (result) {
                    return res.status(200).json({ "success": true, "recordId": result.id });
                }
                else {
                    res.status(200).json({ "success": false, "message": "No Record Found!" });
                }
            }
            else {
                return res.status(200).json({ "success": false, "id": duplicate.id, "message": "Record already exists." });
            }
        });


    //update Record
    router.put("/:id", fetchUser, async (req, res) => {//Check permissions
        try {



            const { attendance_id, present, absent } = req.body;
            const errors = [];
            const attRecord = {};

            if (req.body.hasOwnProperty("attendance_id")) { attRecord.attendance_id = attendance_id };
            if (req.body.hasOwnProperty("present")) { attRecord.present = present };
            if (req.body.hasOwnProperty("absent")) { attRecord.absent = absent };

            if (errors.length !== 0) {
                return res.status(400).json({ errors: errors });
            }
            attendanceModel.init(req.userinfo.tenantcode);
            let result = await attendanceModel.getRecordById(req.params.id);

            if (result) {

                let responce = await attendanceModel.updateRecordById(req.params.id, attRecord, req.userinfo.id);

                if (responce) {

                    return res.status(200).json({ "success": true, "message": "Record updated successfully" });
                } else {

                    return res.status(200).json({ "success": false, "message": "Bad Request" });
                }
            } else {
                return res.status(200).json({ "success": false, "message": "No record found" });
            }
        } catch (error) {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
    });



    app.use(process.env.BASE_API_URL + '/api/attendance', router);
}


