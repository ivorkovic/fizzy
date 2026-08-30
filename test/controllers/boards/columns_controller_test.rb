require "test_helper"

class Boards::ColumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "show" do
    get board_column_path(boards(:writebook), columns(:writebook_in_progress))
    assert_response :success
  end

  test "show is not served from cache when a card leaves a full first page" do
    column = columns(:writebook_in_progress)
    cards = Current.set(account: accounts("37s"), user: users(:kevin)) do
      16.times.map do |i|
        column.board.cards.create! title: "Card-#{i}-", creator: users(:kevin), status: "published",
          column: column, last_active_at: (16 - i).minutes.ago
      end
    end
    mover = cards[1] # on the first page of 15, but not the page's newest updated_at

    get board_column_path(column.board, column)
    assert_response :success
    assert_match mover.title, response.body
    etag = response.headers["ETag"]

    Current.set(account: accounts("37s"), user: users(:kevin)) { mover.triage_into columns(:writebook_on_hold) }

    get board_column_path(column.board, column), headers: { "If-None-Match" => etag }
    assert_response :success
    assert_no_match mover.title, response.body
  end

  test "create" do
    assert_difference -> { boards(:writebook).columns.count }, +1 do
      post board_columns_path(boards(:writebook)), params: { column: { name: "New Column" } }, as: :turbo_stream
      assert_response :success
    end

    assert_equal "New Column", boards(:writebook).columns.last.name
  end

  test "create refreshes adjacent columns" do
    board = boards(:writebook)

    post board_columns_path(board), params: { column: { name: "New Column" } }, as: :turbo_stream

    new_column = board.columns.find_by!(name: "New Column")
    new_column.adjacent_columns.each do |adjacent_column|
      assert_turbo_stream action: :replace, target: dom_id(adjacent_column)
    end
  end

  test "update" do
    column = columns(:writebook_in_progress)

    assert_changes -> { column.reload.name }, from: "In progress", to: "Updated Name" do
      put board_column_path(boards(:writebook), column), params: { column: { name: "Updated Name" } }, as: :turbo_stream
      assert_response :success
    end
  end

  test "destroy" do
    column = columns(:writebook_in_progress)
    adjacent_columns = column.adjacent_columns.to_a

    delete board_column_path(column.board, column), as: :turbo_stream

    assert_redirected_to board_path(column.board)
  end

  test "index as JSON" do
    board = boards(:writebook)

    get board_columns_path(board), as: :json

    assert_response :success
    assert_equal board.columns.count, @response.parsed_body.count
    assert_equal board_column_cards_url(board, board.columns.sorted.first), @response.parsed_body.first["cards_url"]
  end

  test "show as JSON" do
    column = columns(:writebook_in_progress)

    get board_column_path(column.board, column), as: :json

    assert_response :success
    assert_equal column.id, @response.parsed_body["id"]
    assert_equal board_column_cards_url(column.board, column), @response.parsed_body["cards_url"]
  end

  test "create as JSON" do
    board = boards(:writebook)

    assert_difference -> { board.columns.count }, +1 do
      post board_columns_path(board), params: { column: { name: "New Column" } }, as: :json
    end

    assert_response :created
    assert_equal board_column_path(board, Column.last, format: :json), @response.headers["Location"]
    assert_equal "New Column", @response.parsed_body["name"]
    assert_equal board_column_cards_url(board, Column.last), @response.parsed_body["cards_url"]
  end

  test "update as JSON" do
    column = columns(:writebook_in_progress)

    put board_column_path(column.board, column), params: { column: { name: "Updated Name" } }, as: :json

    assert_response :success
    assert_equal "Updated Name", column.reload.name

    json = @response.parsed_body
    assert_equal column.id, json["id"]
    assert_equal "Updated Name", json["name"]
  end

  test "destroy as JSON" do
    column = columns(:writebook_on_hold)

    assert_difference -> { column.board.columns.count }, -1 do
      delete board_column_path(column.board, column), as: :json
    end

    assert_response :no_content
  end
end
