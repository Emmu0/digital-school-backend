const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Issue = require("../models/issue.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {
  

    Issue.init(req.userinfo.tenantcode);
    const issues = await Issue.findAll();
    if (issues) {
      res.status(200).json(issues);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


//   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {
     
  
      const issueId = req.params.id;
      Issue.init(req.userinfo.tenantcode);
      const issue = await Issue.findByIssueId(issueId);
      if (issue) {
        res.status(200).json(issue);
      } else {
        res.status(404).json({ errors: "Issue not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Get By BookId---------------------------
  router.get("/bookid/:id", fetchUser, async (req, res) => {
    try {
      
  
      const bookId = req.params.id;
      Issue.init(req.userinfo.tenantcode);
      const issue = await Issue.findByBookId(bookId);
      if (issue) {
        res.status(200).json(issue);
      } else {
        res.status(404).json({ errors: "Issue not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });
  

  //   ---------------------Create New Issue---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {
      

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Issue.init(req.userinfo.tenantcode);

      const issueRecord = await Issue.createIssue(req.body, req.userinfo.id);

      if (!issueRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(issueRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

    //   ---------------------Update Issue by Id---------------------------

    router.put("/:id", fetchUser, [], async (req, res) => {
      
      
  
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const issueId = req.params.id;
      const issueData = req.body;
      Issue.init(req.userinfo.tenantcode);
      const updateIssue = await Issue.updateById(
          issueId,
          issueData,
          req.userinfo.id
      );
      
      if (updateIssue) {
                return res.status(200).json({ success: true, message: "Record updated successfully" });
              }
              return res.status(200).json(updateIssue);
    });
 //   ----------------------- Delete Issue -------------------

 router.delete("/:id", fetchUser, async (req, res) => {

   
  
    Issue.init(req.userinfo.tenantcode);
    const result = await Issue.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });
  
    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });
  

  app.use(process.env.BASE_API_URL + "/api/issues", router);
};
