/**
 * Handles all incoming request for /api/Students endpoint
 * DB table for this public.Student
 * Model used here is Student.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/previousSchool
 *              GET     /api/previousSchool/:id
 *              POST    /api/previousSchool
 *              PUT     /api/previousSchool/:id
 *              DELETE  /api/previousSchool/:id
 *
 * @author      Pooja Vaishnav
 * @date        22 Sept 2023
 * @copyright   www.ibirdsservices.com
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Previousschool = require("../models/previousschool.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.post("/", fetchUser, [],async (req, res) => {
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      console.log('req.body%%%=>', req.body)
      Previousschool.init(req.userinfo.tenantcode);
      let duplicate = await Previousschool.duplicateRecord(null, req.body);//check duplicate Record
      console.log('duplicate rec==>',duplicate)
      if (duplicate === null) {
        console.log('inside the if$$$$')
        const PreviousSchoolRec = await Previousschool.createPreviousSchool(req.body, req.userinfo.id);
        console.log('ficontactRec@@==>rst',PreviousSchoolRec)
        if (PreviousSchoolRec != null) {
          console.log('inside the first 1')
          return res.status(200).json({ "success": true, result:PreviousSchoolRec});
        }else{
          console.log('inside the second 1')
          return res.status(400).json({ errors: "Bad Request" });
        } 
      }else {
        console.log('inside the else$$$$')
        console.log('inside the DuplicateHHHH') 
        return res.status(200).json({ "success": false, "message": "Previous school is already exist with this phone number" });
      }
      return res.status(201).json(PreviousSchoolRec);
    }
  );
  app.use(process.env.BASE_API_URL + "/api/previousSchool", router);
};