package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func SubmitContacts(c *gin.Context) {
	var req struct {
		DeviceID string             `json:"device_id"`
		Contacts []models.ContactRecord `json:"contacts"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.DeviceID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "device_id required"})
		return
	}
	deviceID := req.DeviceID

	database.DB.Where("device_id = ?", deviceID).Delete(&models.ContactRecord{})

	if len(req.Contacts) > 0 {
		for i := range req.Contacts {
			req.Contacts[i].DeviceID = deviceID
		}
		database.DB.Create(&req.Contacts)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Contacts saved", "count": len(req.Contacts)})
}
