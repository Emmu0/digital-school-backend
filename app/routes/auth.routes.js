/**
 * Handles all incoming request for /api/auth endpoint
 * DB table for this public.user
 * Model used here is auth.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/auth/getuser
 *              POST    /api/createuser
 *              POST     /api/login
 * 
 * @author      Aslam Bari
 * @date        Feb, 2023
 * @copyright   www.ibirdsservices.com
 */

const e = require("express");
const Auth = require("../models/auth.model.js");
const File = require("../models/file.model.js");
const fs = require('fs');
const { fetchUser } = require("../middleware/fetchuser.js");
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { closeSync } = require("fs");

module.exports = app => {

  const { body, validationResult } = require('express-validator');

  var router = require("express").Router();

  // Create a new Tutorial
  router.post("/createuser", [
    body('email', 'Please enter email').isEmail(),
    body('password', 'Please enter password').isLength({ min: 6 }),
    body('firstname', 'Please enter firstname').isLength({ min: 2 }),
    body('lastname', 'Please enter lastname').isLength({ min: 2 })
  ],


    async (req, res) => {
      const { firstname, lastname, email, password } = req.body;
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const salt = bcrypt.genSaltSync(10);
      const secPass = bcrypt.hashSync(req.body.password, salt);
      Auth.init(req.userinfo.tenantcode);
      const newUser = await Auth.createUser({
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: secPass
      });
      if (newUser) {
        const data = {
          id: newUser.id
        };

        const authToken = jwt.sign(data, process.env.JWT_SECRET);

        return res.status(201).json({ authToken });
      }
      else
        return res.status(400).json({ errors: "Bad request" });

      // contacts.create(req, res);

    });

  // -------------- Login -----------------
  router.post("/login", [
    body('email', 'Please enter firstname').isEmail(),
    body('password', 'Please enter password').isLength({ min: 1 })
  ],

    async (req, res) => {
      let success = false;
      try {

        const { email, password, schoolcode, type } = req.body;
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({ success, errors: errors.array() });
        }

        if (req.body.type && req.body.schoolcode && (req.body.type === 'PARENT' || req.body.type === 'STUDENT')) {

          const userRec = await Auth.findByEmail(email, schoolcode, type);

          const permissionsStringified = JSON.parse(JSON.stringify(userRec?.userinfo?.permissions));

          userRec.userinfo.permissions = permissionsStringified ? permissionsStringified : '';



          if (!userRec) {
            return res.status(400).json({ success, errors: "Try to login with correct credentials" });
          }

          if (password !== userRec.userinfo.password) {
            return res.status(400).json({ success, errors: "Enter Correct Password" });
          }

          const authToken = jwt.sign(userRec.userinfo, process.env.JWT_SECRET, { expiresIn: '5h' });
          success = true;
          // const permissions = userInfo.permissions;
          return res.status(201).json({ success, authToken });

        }
        else {
          const userRec = await Auth.findByEmail(email);
          console.log("userRec: ", userRec);
          if (!userRec) {
            return res.status(400).json({ success, errors: "Try to login with correct credentials 123" });
          }
          const userInfo = userRec.userinfo;
          console.log("passwprd: ", userInfo.password, password)
          const passwordCompare = await bcrypt.compare(password, userInfo.password);

          console.log("password:compare", passwordCompare);

          if (!passwordCompare) {
            return res.status(400).json({ success, errors: "Try to login with correct credentials" });
          }

          //removing sensitive data from token
          delete userInfo.password;
          delete userInfo.email;
          let username = userInfo.firstname + ' ' + userInfo.lastname;
          let userrole = userInfo.userrole;
          let companyname = userInfo.companyname;
          let companystreet = userInfo.companystreet;
          let companycity = userInfo.companycity;
          let companypincode = userInfo.companypincode;
          let companystate = userInfo.companystate;
          let companycountry = userInfo.companycountry;
          let logourl = userInfo.logourl;
          let sidebarbgurl = userInfo.sidebarbgurl;
          let tenantcode = userInfo.tenantcode;
          delete userInfo.firstname;
          delete userInfo.lastname;
          const authToken = jwt.sign(userInfo, process.env.JWT_SECRET, { expiresIn: '5h' });
          success = true;
          const permissions = userInfo.permissions;
          return res.status(201).json({ success, authToken });

        }


      } catch (error) {

        res.status(400).json({ success, errors: error });
      }
      // contacts.create(req, res);

    });

  //......................................Update User.................................
  router.put("/:id", fetchUser, async (req, res) => {
    try {
      //Check permissions
      //  firstname, lastname, fathername, gender, street, city, state, pincode, phone, doj, adharcard, designation, panno, email, password, dob, manager, country, location, userrole} = newUser;

      const { firstname, lastname, fathername, doj, designation, panno, email, phone, dob, gender, bankdetails, adharcard, street, city, state, country, pincode, location, manager, userrole, password, isactive } = req.body;
      const errors = [];
      const userRec = {};

      if (req.body.hasOwnProperty("firstname")) { userRec.firstname = firstname; if (!firstname) { errors.push('Firstname is required') } };
      if (req.body.hasOwnProperty("lastname")) { userRec.lastname = lastname; if (!lastname) { errors.push('Lastname is required') } };
      if (req.body.hasOwnProperty("fathername")) { userRec.fathername = fathername };
      if (req.body.hasOwnProperty("email")) { userRec.email = email; if (!email) { errors.push('Email is required') } };
      if (req.body.hasOwnProperty("password")) { userRec.password = password; if (!password) { errors.push('Password is required') } };
      if (req.body.hasOwnProperty("phone")) { userRec.phone = phone };
      if (req.body.hasOwnProperty("dob")) { userRec.dob = dob };
      if (req.body.hasOwnProperty("gender")) { userRec.gender = gender };
      if (req.body.hasOwnProperty("bankdetails")) { userRec.bankdetails = bankdetails };
      if (req.body.hasOwnProperty("adharcard")) { userRec.adharcard = adharcard };
      if (req.body.hasOwnProperty("street")) { userRec.street = street };
      if (req.body.hasOwnProperty("city")) { userRec.city = city };
      if (req.body.hasOwnProperty("state")) { userRec.state = state };
      if (req.body.hasOwnProperty("country")) { userRec.country = country };
      if (req.body.hasOwnProperty("pincode")) { userRec.pincode = pincode };
      if (req.body.hasOwnProperty("panno")) { userRec.panno = panno };
      if (req.body.hasOwnProperty("manager")) { userRec.manager = manager };
      if (req.body.hasOwnProperty("doj")) { userRec.doj = doj };
      if (req.body.hasOwnProperty("userrole")) { userRec.userrole = userrole };
      if (req.body.hasOwnProperty("isactive")) { userRec.isactive = isactive };
      if (req.body.hasOwnProperty("designation")) { userRec.designation = designation };
      if (req.body.hasOwnProperty("location")) { userRec.location = location };


      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }

      Auth.init(req.userinfo.tenantcode);
      let resultUser = await Auth.findById(req.params.id);

      if (resultUser) {



        if (req.body.hasOwnProperty("password")) {
          const salt = bcrypt.genSaltSync(10);
          const secPass = bcrypt.hashSync(req.body.password, salt);
          userRec.password = secPass;
        }


        resultUser = await Auth.updateRecById(req.params.id, userRec, req.userinfo.id);
        if (resultUser) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        }
        return res.status(200).json(resultUser);


      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }


    } catch (error) {

      res.status(400).json({ errors: error });
    }

  });


  router.put("/updatepassword", fetchUser, async (req, res) => {
    try {
      //Check permissions

      const { password } = req.body;
      const errors = [];
      const userRec = {};
      const salt = bcrypt.genSaltSync(10);
      const secPass = bcrypt.hashSync(req.body.password, salt);
      if (req.body.hasOwnProperty("password")) { userRec.password = secPass };
      //if(req.body.hasOwnProperty("id")){userRec.id = id};

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      Auth.init(req.userinfo.tenantcode);
      let resultUser = await Auth.findById(req.userinfo.id);

      if (resultUser) {

        resultLead = await Auth.updateById(req.userinfo.id, userRec);

        if (resultLead) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        }



      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }


    } catch (error) {

      res.status(400).json({ errors: error });
    }

  });



  // Update profile - 31 May

  router.put("/:id/profile", fetchUser, async (req, res) => {
    const MIMEType = new Map([
      ["text/csv", "csv"],
      ["application/msword", "doc"],
      ["application/vnd.openxmlformats-officedocument.wordprocessingml.document", "docx"],
      ["image/gif", "gif"],
      ["text/html", "html"],
      ["image/jpeg", "jpg"],
      ["image/jpg", "jpg"],
      ["application/json", "json"],
      ["audio/mpeg", "mp3"],
      ["video/mp4", "mp4"],
      ["image/png", "png"],
      ["application/pdf", "pdf"],
      ["application/vnd.ms-powerpoint", "ppt"],
      ["application/vnd.openxmlformats-officedocument.presentationml.presentation", "pptx"],
      ["image/svg+xml", "svg"],
      ["text/plain", "txt"],
      ["application/vnd.ms-excel", "xls"],
      ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "xlsx"],
      ["text/xm", "xml"],
      ["application/xml", "xml"],
      ["application/atom+xml", "xml"],
      ["application/zip", "zip"],
    ]);
    File.init(req.userinfo.tenantcode);
    Auth.init(req.userinfo.tenantcode);
    const resultFile = await File.findByParentId(req.params.id);

    if (resultFile) {
      for (const value of resultFile) {
        const fileId = value.id;
        const fileTitle = value.title;
        const fileType = value.filetype;
        const parentId = value.parentid;
        const filePath = `${process.env.FILE_UPLOAD_PATH}/users/${parentId}/${parentId}`;

        if (fs.existsSync(filePath)) {
          const result = await File.deleteFile(fileId);
          if (!result) {
            return res.status(200).json({ "success": false, "message": "No record found" });
          } else {
            fs.unlinkSync(filePath);
            const pdfreference = req.files.file;
            const newVersiorecord = JSON.parse(JSON.parse(req.body.staffRecord));

            delete newVersiorecord.managername;
            delete newVersiorecord.username;
            const resultObj = await Auth.findById(req.userinfo.id);

            if (resultObj) {

              const result = await Auth.updateRecById(resultObj.id, newVersiorecord, req.userinfo.id);
              if (!result) {
                return res.status(400).json({ errors: "Bad Request" });
              }

              const newReq = {
                "title": pdfreference.name,
                "filetype": MIMEType.get(pdfreference.mimetype) || pdfreference.mimetype,
                "parentid": resultObj.id,
                "filesize": pdfreference.size
              };

              const fileRec = await File.create(newReq, req.userinfo.id);
              const uploadPath = `${process.env.FILE_UPLOAD_PATH}/users`;

              const filePath = `${uploadPath}/${fileRec.parentid}/${fileRec.parentid}`;

              try {
                if (fs.existsSync(uploadPath)) {
                  pdfreference.mv(filePath, (err) => {
                    if (err) {
                      return res.send(err);
                    }
                  });
                } else {
                  fs.mkdirSync(uploadPath, { recursive: true });
                  pdfreference.mv(filePath, (err) => {
                    if (err) {
                      return res.send(err);
                    }
                  });
                }
              } catch (e) {

              }

              return res.status(201).json(result);
            }
            return res.status(200).json({ "success": true, "message": "Successfully Deleted" });
          }
        }
      }
    }

    const pdfreference = req?.files?.file;
    const newVersiorecord = JSON.parse(JSON.parse(req.body.staffRecord));
    delete newVersiorecord.managername;
    delete newVersiorecord.username;
    const resultObj = await Auth.findById(req.userinfo.id);

    if (resultObj) {

      const result = await Auth.updateRecById(resultObj.id, newVersiorecord, req.userinfo.id);
      if (!result) {
        return res.status(400).json({ errors: "Bad Request" });
      }
      if (pdfreference) {
        const newReq = {
          "title": pdfreference.name,
          "filetype": MIMEType.get(pdfreference.mimetype) || pdfreference.mimetype,
          "parentid": resultObj.id,
          "filesize": pdfreference.size
        };

        const fileRec = await File.create(newReq, req.userinfo.id);
        const uploadPath = `${process.env.FILE_UPLOAD_PATH}/users/${resultObj.id}/`;
        const filePath = `${uploadPath}${fileRec.parentid}`;
        try {
          if (fs.existsSync(uploadPath)) {
            pdfreference.mv(filePath, (err) => {
              if (err) {
                return res.send(err);
              }
            });
          } else {
            fs.mkdirSync(uploadPath, { recursive: true });
            pdfreference.mv(filePath, (err) => {
              if (err) {
                return res.send(err);
              }
            });
          }
        } catch (e) {

        }
        return res.status(201).json(result);
      }
    }
  });

  router.get("/myimage", fetchUser, async (req, res) => {
    try {

      let filePath = process.env.FILE_UPLOAD_PATH + "/users/" + req.userinfo.id + "/" + req.userinfo.id;
      Auth.init(req.userinfo.tenantcode);
      res.download(filePath, "myprofileimage", function (err) {
        if (err) {
          return res.status(400).json({ "Error": false, "message": err });
        }
      });
    } catch (error) {

      return res.status(400).json({ "Error": false, "message": error });
    }
  });

  // Create a new Tutorial
  router.get("/getuser", fetchUser,

    async (req, res) => {

      try {

        const userid = req.userinfo.id;

        Auth.init(req.userinfo.tenantcode);
        const userRec = await Auth.findById(userid);

        if (!userRec) {
          return res.status(400).json({ errors: "User not found" });
        }

        return res.status(201).json(userRec);

      } catch (error) {

        res.status(400).json({ errors: error });
      }


    });
  // Fetch all Users
  router.get("/", fetchUser,

    async (req, res) => {

      try {
        Auth.init(req.userinfo.tenantcode);
        const userRec = await Auth.findAll();
        if (!userRec) {
          return res.status(400).json({ errors: "User not found" });
        }
        return res.status(201).json(userRec);

      } catch (error) {

        res.status(400).json({ errors: error });
      }


    });

  // Fetch all Users

  app.use(process.env.BASE_API_URL + '/api/auth', router);
};