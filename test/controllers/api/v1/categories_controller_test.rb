require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { @headers = auth_headers("lucia-token") }

  test "crea una categoría propia de un hogar del usuario" do
    assert_difference -> { households(:martinez).categories.count }, 1 do
      post api_v1_categories_path, params: { category: {
        household_id: households(:martinez).id, name: "Mascotas", color: "#C9A86A"
      } }, headers: @headers, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "Mascotas", body["name"]
    assert_equal households(:martinez).id, body["household_id"]
    assert_equal false, body["global"]
  end

  test "en un hogar ajeno da 404" do
    assert_no_difference -> { Category.count } do
      post api_v1_categories_path, params: { category: {
        household_id: households(:gomez).id, name: "Jardín"
      } }, headers: @headers, as: :json
    end

    assert_response :not_found
  end

  test "nunca crea categorías globales" do
    assert_no_difference -> { Category.global.count } do
      post api_v1_categories_path, params: { category: { name: "Sin hogar" } }, headers: @headers, as: :json
    end

    assert_response :bad_request
    assert_match "household_id", response.parsed_body["errors"].first
  end

  test "valida el nombre repetido dentro del hogar" do
    post api_v1_categories_path, params: { category: {
      household_id: households(:martinez).id, name: "servicios"
    } }, headers: @headers, as: :json

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Nombre ya está en uso"
  end
end
