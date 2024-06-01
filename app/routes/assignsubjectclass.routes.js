/**
 * @author: Abdul Pathan
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const assignSubject = require("../models/assignsubjectclass.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();

    //All Records
    router.get("/:?", fetchUser, async (req, res) => {    //Check permissions

        const classId = req.query.class_id;
        assignSubject.init(req.userinfo.tenantcode);
        const result = await assignSubject.getRecords(classId); //get Records
        if (result) {
            return res.status(200).json({ "success": true, 'records': result });
        } else {
            return res.status(200).json({ "success": false, "message": "No record found" });
        }
    });

    //add Record
    router.post("/", fetchUser, [
        body('class_id', 'Please enter class Name').isLength({ min: 1 }),
        body('subject_id', 'Please enter subject Name').isLength({ min: 1 }),
    ],

        async (req, res) => {    //Check permissions
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }
            assignSubject.init(req.userinfo.tenantcode);
            const duplicateRecord = await assignSubject.duplicateRecord(null, req.body);//check duplicate subject class record
            if (!duplicateRecord) {
                let result = await assignSubject.addRecord(req.body, req.userinfo.id);//add Record
                if (result) {
                    return res.status(200).json({ "success": true, 'record': result });
                } else {
                    return res.status(200).json({ "success": false, "message": "Bad Request" });
                }
            }
            else {
                return res.status(200).json({ "success": false, "message": "Record already exists." });
            }
        });


    //delete Record
    router.delete("/:id", fetchUser, async (req, res) => {  //Check permissions
        assignSubject.init(req.userinfo.tenantcode);
        const result = await assignSubject.deleteRecord(req.params.id);//delete Record
        console.log('ResultData==>', result);
        if (!result)
            return res.status(200).json(
                {
                    "success": false,
                    "message": "No record found"
                });

        res.status(200).json(
            {
                "success": true,
                "message": "Successfully Deleted"
            });
    });

    //get RecordById
    router.get("/:id", fetchUser, async (req, res) => {    //Check permissions
        try {

            assignSubject.init(req.userinfo.tenantcode);
            let result = await assignSubject.getRecordById(req.params.id);//get Record By Id
            if (result) {
                return res.status(200).json(result);
            } else {
                return res.status(200).json({ "success": false, "message": "No record found" });
            }
        } catch (error) {
            return res.status(400).json({ "success": false, "message": error });
        }
    });


    app.use(process.env.BASE_API_URL + '/api/assignsubjectclass', router);
};