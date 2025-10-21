package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/gorilla/mux"
)

type ProductHandler struct {
	repo *repository.ProductRepository
}

func NewProductHandler(repo *repository.ProductRepository) *ProductHandler {
	return &ProductHandler{repo: repo}
}

// CreateProduct handles POST /api/v1/locations/{location_id}/products
func (h *ProductHandler) CreateProduct(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	var req models.CreateProductRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate required fields
	if req.Name == "" || req.Price <= 0 {
		respondWithError(w, http.StatusBadRequest, "Name and price (> 0) are required")
		return
	}

	product, err := h.repo.Create(locationID, &req)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to create product")
		return
	}

	respondWithJSON(w, http.StatusCreated, product)
}

// GetProduct handles GET /api/v1/products/{product_id}
func (h *ProductHandler) GetProduct(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	productID := vars["product_id"]

	product, err := h.repo.GetByID(productID)
	if err != nil {
		if err.Error() == "product not found" {
			respondWithError(w, http.StatusNotFound, "Product not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to get product")
		return
	}

	respondWithJSON(w, http.StatusOK, product)
}

// UpdateProduct handles PUT /api/v1/products/{product_id}
func (h *ProductHandler) UpdateProduct(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	productID := vars["product_id"]

	var req models.UpdateProductRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	product, err := h.repo.Update(productID, &req)
	if err != nil {
		if err.Error() == "product cannot be updated: menu is not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		if err.Error() == "product not found" {
			respondWithError(w, http.StatusNotFound, "Product not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to update product")
		return
	}

	respondWithJSON(w, http.StatusOK, product)
}

// DeleteProduct handles DELETE /api/v1/products/{product_id}
func (h *ProductHandler) DeleteProduct(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	productID := vars["product_id"]

	err := h.repo.Delete(productID)
	if err != nil {
		if err.Error() == "product cannot be deleted: menu is not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		if err.Error() == "product not found" {
			respondWithError(w, http.StatusNotFound, "Product not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to delete product")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ToggleAvailability handles PATCH /api/v1/products/{product_id}/availability
func (h *ProductHandler) ToggleAvailability(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	productID := vars["product_id"]

	var req models.ToggleAvailabilityRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	err := h.repo.ToggleAvailability(productID, req.IsAvailable)
	if err != nil {
		if err.Error() == "product not found" {
			respondWithError(w, http.StatusNotFound, "Product not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to toggle availability")
		return
	}

	product, _ := h.repo.GetByID(productID)
	respondWithJSON(w, http.StatusOK, product)
}
