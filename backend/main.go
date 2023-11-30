package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	_ "github.com/mattn/go-sqlite3"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Todo struct {
	ID        uuid.UUID `json:"id" gorm:"primary_key"`
	Name      string    `json:"name"`
	Completed bool      `json:"completed" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`
}

type CreateTodo struct {
	Name      string `json:"name" binding:"required"`
	Completed bool   `json:"completed"`
}

type UpdateTodo struct {
	Name      string `json:"name"`
	Completed *bool  `json:"completed"`
}

var DB *gorm.DB

func ConnectDatabase() {
	database, err := gorm.Open(sqlite.Open("todo.db"), &gorm.Config{})
	if err != nil {
		panic("Failed to connect to database!")
	}
	err = database.AutoMigrate(&Todo{})
	if err != nil {
		return
	}
	DB = database
}

func main() {
	router := gin.Default()
	ConnectDatabase()

	router.GET("/todos", func(ctx *gin.Context) {
		var todos []Todo
		DB.Find(&todos)
		ctx.JSON(http.StatusOK, gin.H{"data": todos})
	})

	router.POST("/todos", func(ctx *gin.Context) {
		var input CreateTodo
		if err := ctx.ShouldBindJSON(&input); err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		todo := Todo{Name: input.Name, Completed: input.Completed, ID: uuid.New()}
		DB.Create(&todo)

		ctx.JSON(http.StatusOK, gin.H{"data": todo})
	})

	router.GET("/todos/:id", func(ctx *gin.Context) {
		id := ctx.Param("id")
		var todo Todo
		if err := DB.Where("id = ?", id).First(&todo).Error; err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Not Found"})
			return
		}
		ctx.JSON(http.StatusOK, gin.H{"data": todo})
	})

	router.PATCH("/todos/:id", func(ctx *gin.Context) {
		id := ctx.Param("id")
		var todo Todo
		if err := DB.Where("id = ?", id).First(&todo).Error; err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Not found"})
			return
		}
		var input UpdateTodo
		if err := ctx.ShouldBindJSON(&input); err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		DB.Model(&todo).Where("id = ?", id).Updates(input)
		ctx.JSON(http.StatusOK, gin.H{"data": todo})
	})

	router.DELETE("/todos/:id", func(ctx *gin.Context) {
		id := ctx.Param("id")
		var todo Todo
		if err := DB.Where("id = ?", id).First(&todo).Error; err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Not found"})
			return
		}
		DB.Where("id = ?", id).Delete(&todo)
		ctx.JSON(http.StatusOK, gin.H{"data": true})
	})

	router.Run("localhost:9090")
}
