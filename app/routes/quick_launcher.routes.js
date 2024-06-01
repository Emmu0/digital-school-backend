const { fetchUser } = require("../middleware/fetchuser");
//const permissions = require("../constants/permissions.js");

module.exports = (quickLaucher) => {
  const { body, validationResult } = require("express-validator");
  var router = require("express").Router();
  const quick_launcherModel = require("../models/quick_launcher.model.js");

  router.post("/", fetchUser, [], async (req, res) => {
   
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    const body = req.body;

    console.log(body, req.userinfo.id, "body ==>");
    quick_launcherModel.init(req.userinfo.tenantcode);
    const result = await quick_launcherModel.createQuickLauncher(
      body,
      req.userinfo.id
    );
    if (result) {
      return res
        .status(200)
        .json({ success: true, message: "Record Save Successfully." });
    } else {
      return res.status(401).json({ success: false, message: "Bad Request" });
    }
  });

  router.get("/", fetchUser, [], async (req, res) => {
    
    quick_launcherModel.init(req.userinfo.tenantcode);
    const result = await quick_launcherModel.getAllQuickLauncher(
      req.userinfo.id
    );
    if (result) {
      return res.status(200).json({ success: true, records: result });
    } else {
      return res.status(200).json({ success: false, message: "Bad Request" });
    }
  });

  router.delete("/:id", fetchUser, [], async (req, res) => {
    console.log(req.params.id, "req.params.id quicklauncher");

   
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    quick_launcherModel.init(req.userinfo.tenantcode);
    const result = await quick_launcherModel.deleteQuickLaucer(req.params.id);
    if (result) {
      return res.status(200).json({ success: true, records: result });
    } else {
      return res.status(401).json({ success: false, message: "Bad Request" });
    }
  });

  quickLaucher.use("/api/quicklaucher", router);
};
