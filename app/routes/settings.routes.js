/**
 * @author: Pawan Singh Sisodiya
 */

const { createSetting, updateRecordById, deleteSetting, getSettings, init } = require("../models/settings.model.js");
const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");
  const router = require("express").Router();

  // Create Setting
  router.post("/", fetchUser,
    [
      body("key").notEmpty().isString(),
      body("value").notEmpty().isString(),
    ],
    async (req, res) => {
      try {

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({ errors: errors.array() });
        }

        const settingData = req.body;
        init(req.userinfo.tenantcode);
        const settingResult = await createSetting(settingData);

        if (!settingResult) {
          return res.status(400).json({success: false, error: "Bad Request" });
        }
        return res.status(201).json({success: true, data: settingResult});
      } catch (error) {
        console.log("System Error:", error);
        return res.status(500).json({ success: false, message: "Internal Server Error" });
      }
    }
  );

  // Get all Settings
  router.get("/:key?", fetchUser, async (req, res) => {
    try {

      init(req.userinfo.tenantcode);
      const allSettings = await getSettings(req?.params?.key);
      if (allSettings) {
        res.status(200).json({success: true, data: allSettings});
      } else {
        res.status(200).json({success: false, errors: "No data" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
  });


  // Delete Setting
  router.delete("/:id", fetchUser, async (req, res) => {
    try {
      // Check permissions
      const settingId = req.params.id;
      init(req.userinfo.tenantcode);
      const settingResult = await deleteSetting(settingId);

      if (settingResult) {
        return res.status(200).json({ success: true, message: "Setting deleted successfully" });
      } else {
        return res.status(404).json({ success: false, message: "Setting not found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
  });

  // Update Setting
  router.put("/:id", fetchUser, async (req, res) => {
    try {

      const settingId = req.params.id;
      const settingData = req.body;
      init(req.userinfo.tenantcode);
      const updatedSetting = await updateRecordById(settingId, settingData);

      if (!updatedSetting) {
        return res.status(404).json({ error: "Setting not found" });
      }

      return res.status(200).json(updatedSetting);
    } catch (error) {
      console.log("System Error:", error);
      return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
  });

  app.use(process.env.BASE_API_URL + "/api/settings", router);
};
