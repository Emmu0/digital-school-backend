const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Language = require("../models/language.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {
    

    Language.init(req.userinfo.tenantcode);
    const language = await Language.findAll();
    if (language) {
      res.status(200).json(language);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


//   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {
     
  
      const languageId = req.params.id;
      Language.init(req.userinfo.tenantcode);
      const language = await Language.findByLanguageId(languageId);
      if (language) {
        res.status(200).json(language);
      } else {
        res.status(404).json({ errors: "Language not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });
  

  //   ---------------------Create New Language---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {
     

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Language.init(req.userinfo.tenantcode);

      const languageRecord = await Language.createLanguage(req.body, req.userinfo.id);

      if (!languageRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(languageRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

    //   ---------------------Update Language by Id---------------------------

    router.put("/:id", fetchUser, [], async (req, res) => {
      
     
  
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const languageId = req.params.id;
      const languageData = req.body;
      Language.init(req.userinfo.tenantcode);
      const updateLanguage = await Language.updateById(
          languageId,
          languageData,
          req.userinfo.id
      );
      
      if (updateLanguage) {
                return res.status(200).json({ success: true, message: "Record updated successfully" });
              }
              return res.status(200).json(updateLanguage);
    });


 //   ----------------------- Delete Language -------------------

 router.delete("/:id", fetchUser, async (req, res) => {
    
  
    Language.init(req.userinfo.tenantcode);
    const result = await Language.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });
  
    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });
  

  app.use(process.env.BASE_API_URL + "/api/languages", router);
};
