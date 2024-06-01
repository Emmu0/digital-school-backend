const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Publisher = require("../models/publisher.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {
   
    Publisher.init(req.userinfo.tenantcode);
    const publishers = await Publisher.findAll();
    if (publishers) {
      res.status(200).json(publishers);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


//   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {
      
  
      const publisherId = req.params.id;
      Publisher.init(req.userinfo.tenantcode);
      const publisher = await Publisher.findByPublisherId(publisherId);
      if (publisher) {
        res.status(200).json(publisher);
      } else {
        res.status(404).json({ errors: "Publisher not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });
  

  //   ---------------------Create New Publisher---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {
     

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Publisher.init(req.userinfo.tenantcode);

      const publisherRecord = await Publisher.createPublisher(req.body, req.userinfo.id);

      if (!publisherRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(publisherRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

    //   ---------------------Update Publisher by Id---------------------------

    router.put("/:id", fetchUser, [], async (req, res) => {
      console.log('Publisher update')
      
      
  
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const publisherId = req.params.id;
      console.log("publisherId=====>", publisherId);
      const publisherData = req.body;
      console.log("publisherData=====>", publisherData);
      Publisher.init(req.userinfo.tenantcode);
      const updatePublisher = await Publisher.updateById(
          publisherId,
          publisherData,
          req.userinfo.id
      );
      console.log("updatePublisher==========>", updatePublisher);
      
      if (updatePublisher) {
                return res.status(200).json({ success: true, message: "Record updated successfully" });
              }
              return res.status(200).json(updatePublisher);
    });

 //   ----------------------- Delete Publisher -------------------

 router.delete("/:id", fetchUser, async (req, res) => {
    
    Publisher.init(req.userinfo.tenantcode);
    const result = await Publisher.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });
  
    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });
  

  app.use(process.env.BASE_API_URL + "/api/publishers", router);
};
