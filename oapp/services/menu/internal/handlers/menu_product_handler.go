package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/gorilla/mux"
)

type MenuProductHandler struct {
	repo *repository.MenuProductRepository
}

func NewMenuProductHandler(repo *repository.MenuProductRepository) *MenuProductHandler {
	return &MenuProductHandler{repo: repo}
}

// AddProductToMenu handles POST /api/v1/menus/{menu_id}/products
func (h *MenuProductHandler) AddProductToMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	var req models.AddProductToMenuRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	err := h.repo.AddProduct(menuID, &req)
	if err != nil {
		if err.Error() == "menu not found" || err.Error() == "product not found" || err.Error() == "collection not found" {
			respondWithError(w, http.StatusNotFound, err.Error())
			return
		}
		if err.Error() == "product already in menu" || err.Error() == "menu is not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to add product to menu")
		return
	}

	respondWithJSON(w, http.StatusCreated, map[string]string{"message": "Product added to menu successfully"})
}

// RemoveProductFromMenu handles DELETE /api/v1/menus/{menu_id}/products/{product_id}
func (h *MenuProductHandler) RemoveProductFromMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]
	productID := vars["product_id"]

	err := h.repo.RemoveProduct(menuID, productID)
	if err != nil {
		if err.Error() == "menu not found" {
			respondWithError(w, http.StatusNotFound, "Menu not found")
			return
		}
		if err.Error() == "product not found in menu" {
			respondWithError(w, http.StatusNotFound, err.Error())
			return
		}
		if err.Error() == "menu is not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to remove product from menu")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ReorderProducts handles PUT /api/v1/collections/{collection_id}/products/reorder
func (h *MenuProductHandler) ReorderProducts(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	collectionID := vars["collection_id"]

	var req models.ReorderProductsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	err := h.repo.ReorderProducts(collectionID, req.Products)
	if err != nil {
		respondWithError(w, http.StatusBadRequest, err.Error())
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]string{"message": "Products reordered successfully"})
}
