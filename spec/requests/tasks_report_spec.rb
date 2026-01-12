require 'rails_helper'

RSpec.describe "Tasks Report API", type: :request do
  let!(:genre) { Genre.create!(name: 'テストジャンル') }

  describe 'GET /tasks/report' do
    context 'タスクが存在する場合' do
      before do
        Task.create!(name: 'タスク1', genre: genre, status: 0)
        Task.create!(name: 'タスク2', genre: genre, status: 0)
        Task.create!(name: 'タスク3', genre: genre, status: 1)
        Task.create!(name: 'タスク4', genre: genre, status: 1)
        Task.create!(name: 'タスク5', genre: genre, status: 1)
        Task.create!(name: 'タスク6', genre: genre, status: 2)
      end

      it '正常にレスポンスが返ること' do
        get '/tasks/report'

        expect(response).to have_http_status(:success)
      end

      it 'JSONフォーマットで返ること' do
        get '/tasks/report'

        expect(response.content_type).to include('application/json')
      end

      it 'totalCountが正しいこと' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['totalCount']).to eq(6)
      end

      it 'countByStatusが正しいこと' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['countByStatus']['notStarted']).to eq(2)
        expect(json_response['countByStatus']['inProgress']).to eq(3)
        expect(json_response['countByStatus']['completed']).to eq(1)
      end

      it 'completionRateが正しく計算されること' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        # 1 / 6 * 100 = 16.666... -> 16.7%
        expect(json_response['completionRate']).to eq(16.7)
      end

      it 'レスポンス構造が正しいこと' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('totalCount')
        expect(json_response).to have_key('countByStatus')
        expect(json_response).to have_key('completionRate')
        expect(json_response['countByStatus']).to have_key('notStarted')
        expect(json_response['countByStatus']).to have_key('inProgress')
        expect(json_response['countByStatus']).to have_key('completed')
      end
    end

    context 'タスクが0件の場合' do
      before do
        Task.destroy_all
      end

      it '正常にレスポンスが返ること' do
        get '/tasks/report'

        expect(response).to have_http_status(:success)
      end

      it 'totalCountが0であること' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['totalCount']).to eq(0)
      end

      it 'countByStatusがすべて0であること' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['countByStatus']['notStarted']).to eq(0)
        expect(json_response['countByStatus']['inProgress']).to eq(0)
        expect(json_response['countByStatus']['completed']).to eq(0)
      end

      it 'completionRateが0.0であること' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['completionRate']).to eq(0.0)
      end
    end

    context '完了率の計算が正しいこと' do
      it '完了タスクが0件の場合、0.0%になること' do
        Task.create!(name: 'タスク1', genre: genre, status: 0)
        Task.create!(name: 'タスク2', genre: genre, status: 1)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['completionRate']).to eq(0.0)
      end

      it '全タスクが完了している場合、100.0%になること' do
        Task.create!(name: 'タスク1', genre: genre, status: 2)
        Task.create!(name: 'タスク2', genre: genre, status: 2)
        Task.create!(name: 'タスク3', genre: genre, status: 2)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['completionRate']).to eq(100.0)
      end

      it '完了率が小数点以下1桁で四捨五入されること' do
        # 1完了 / 3タスク = 33.333... -> 33.3%
        Task.create!(name: 'タスク1', genre: genre, status: 0)
        Task.create!(name: 'タスク2', genre: genre, status: 1)
        Task.create!(name: 'タスク3', genre: genre, status: 2)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['completionRate']).to eq(33.3)
      end

      it '完了率が小数点以下1桁で四捨五入されること（切り上げ）' do
        # 2完了 / 3タスク = 66.666... -> 66.7%
        Task.create!(name: 'タスク1', genre: genre, status: 2)
        Task.create!(name: 'タスク2', genre: genre, status: 2)
        Task.create!(name: 'タスク3', genre: genre, status: 0)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['completionRate']).to eq(66.7)
      end
    end

    context 'ステータスの種類が偏っている場合' do
      it '未着手のみの場合' do
        Task.create!(name: 'タスク1', genre: genre, status: 0)
        Task.create!(name: 'タスク2', genre: genre, status: 0)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['totalCount']).to eq(2)
        expect(json_response['countByStatus']['notStarted']).to eq(2)
        expect(json_response['countByStatus']['inProgress']).to eq(0)
        expect(json_response['countByStatus']['completed']).to eq(0)
        expect(json_response['completionRate']).to eq(0.0)
      end

      it '進行中のみの場合' do
        Task.create!(name: 'タスク1', genre: genre, status: 1)
        Task.create!(name: 'タスク2', genre: genre, status: 1)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['totalCount']).to eq(2)
        expect(json_response['countByStatus']['notStarted']).to eq(0)
        expect(json_response['countByStatus']['inProgress']).to eq(2)
        expect(json_response['countByStatus']['completed']).to eq(0)
        expect(json_response['completionRate']).to eq(0.0)
      end

      it '完了のみの場合' do
        Task.create!(name: 'タスク1', genre: genre, status: 2)
        Task.create!(name: 'タスク2', genre: genre, status: 2)

        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['totalCount']).to eq(2)
        expect(json_response['countByStatus']['notStarted']).to eq(0)
        expect(json_response['countByStatus']['inProgress']).to eq(0)
        expect(json_response['countByStatus']['completed']).to eq(2)
        expect(json_response['completionRate']).to eq(100.0)
      end
    end

    context '大量のタスクが存在する場合' do
      before do
        50.times { |i| Task.create!(name: "タスク#{i}", genre: genre, status: 0) }
        30.times { |i| Task.create!(name: "タスク#{i + 50}", genre: genre, status: 1) }
        20.times { |i| Task.create!(name: "タスク#{i + 80}", genre: genre, status: 2) }
      end

      it '正しく集計されること' do
        get '/tasks/report'

        json_response = JSON.parse(response.body)
        expect(json_response['totalCount']).to eq(100)
        expect(json_response['countByStatus']['notStarted']).to eq(50)
        expect(json_response['countByStatus']['inProgress']).to eq(30)
        expect(json_response['countByStatus']['completed']).to eq(20)
        # 20 / 100 * 100 = 20.0%
        expect(json_response['completionRate']).to eq(20.0)
      end
    end
  end
end
