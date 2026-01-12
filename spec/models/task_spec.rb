require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'priority enum' do
    let(:genre) { Genre.create!(name: 'テストジャンル') }

    it '優先度が「低」であること' do
      task = Task.create!(
        name: 'テストタスク',
        genre: genre,
        priority: :low
      )
      expect(task.priority).to eq('low')
      expect(task.low?).to be true
    end

    it '優先度が「中」であること' do
      task = Task.create!(
        name: 'テストタスク',
        genre: genre,
        priority: :medium
      )
      expect(task.priority).to eq('medium')
      expect(task.medium?).to be true
    end

    it '優先度が「高」であること' do
      task = Task.create!(
        name: 'テストタスク',
        genre: genre,
        priority: :high
      )
      expect(task.priority).to eq('high')
      expect(task.high?).to be true
    end
  end

  describe 'default priority' do
    let(:genre) { Genre.create!(name: 'テストジャンル') }

    it '新規タスク作成時に、優先度のデフォルト値が「中」であること' do
      task = Task.create!(
        name: 'デフォルトタスク',
        genre: genre
      )
      expect(task.priority).to eq('medium')
      expect(task.medium?).to be true
    end
  end

  describe '#duplicate' do
    let(:genre) { Genre.create!(name: 'テストジャンル') }

    describe '基本的な複製動作' do
      it '新しいTaskインスタンスを返すこと' do
        original_task = Task.create!(
          name: '元のタスク',
          explanation: 'タスクの説明',
          genre: genre,
          priority: :medium,
          status: 0,
          deadline_date: '2026-12-31'
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task).to be_a(Task)
        expect(duplicated_task).not_to eq(original_task)
      end

      it '新しいレコードとして保存され、IDが異なること' do
        original_task = Task.create!(
          name: '元のタスク',
          genre: genre,
          priority: :high
        )

        duplicated_task = original_task.duplicate
        duplicated_task.save!

        expect(duplicated_task.id).not_to eq(original_task.id)
        expect(duplicated_task.persisted?).to be true
      end

      it 'データベースにレコードが追加されること' do
        original_task = Task.create!(
          name: '元のタスク',
          genre: genre
        )

        expect {
          duplicated_task = original_task.duplicate
          duplicated_task.save!
        }.to change(Task, :count).by(1)
      end

      it '元のタスクは変更されないこと' do
        original_task = Task.create!(
          name: '元のタスク',
          explanation: '説明',
          genre: genre,
          priority: :high,
          status: 1,
          deadline_date: '2026-12-31'
        )

        original_attributes = original_task.attributes.dup

        duplicated_task = original_task.duplicate
        duplicated_task.save!

        original_task.reload
        expect(original_task.attributes).to eq(original_attributes)
      end
    end

    describe '属性の引き継ぎ' do
      it 'nameに「(コピー)」が追加されること' do
        original_task = Task.create!(
          name: 'テストタスク',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.name).to eq('テストタスク(コピー)')
      end

      it 'explanationが引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          explanation: 'これは説明文です',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.explanation).to eq('これは説明文です')
      end

      it 'genre_idが引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.genre_id).to eq(original_task.genre_id)
        expect(duplicated_task.genre).to eq(original_task.genre)
      end

      it 'priority=lowが引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          priority: :low
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.priority).to eq('low')
        expect(duplicated_task.low?).to be true
      end

      it 'priority=mediumが引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          priority: :medium
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.priority).to eq('medium')
        expect(duplicated_task.medium?).to be true
      end

      it 'priority=highが引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          priority: :high
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.priority).to eq('high')
        expect(duplicated_task.high?).to be true
      end
    end

    describe '特別な処理' do
      it 'statusが初期ステータス（0）になること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          status: 1  # 元のステータスは1
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.status).to eq('not_started')
      end

      it '進行中ステータス（status=2）からの複製でも初期ステータスになること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          status: 2
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.status).to eq('not_started')
      end

      it 'deadline_dateがnilになること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          deadline_date: '2026-12-31'
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.deadline_date).to be_nil
      end

      it '元のdeadline_dateが設定されていてもnilになること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          deadline_date: Date.tomorrow
        )

        duplicated_task = original_task.duplicate

        expect(original_task.deadline_date).not_to be_nil
        expect(duplicated_task.deadline_date).to be_nil
      end
    end

    describe 'エッジケース: nameの処理' do
      it 'nameが空文字列の場合、「(コピー)」のみになること' do
        original_task = Task.create!(
          name: '',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.name).to eq('(コピー)')
      end

      it '既に「(コピー)」を含むタスクの複製で二重に追加されること' do
        original_task = Task.create!(
          name: 'タスクA(コピー)',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.name).to eq('タスクA(コピー)(コピー)')
      end

      it '複数回複製すると「(コピー)」が増えること' do
        task1 = Task.create!(
          name: '元タスク',
          genre: genre
        )

        task2 = task1.duplicate
        task2.save!

        task3 = task2.duplicate

        expect(task1.name).to eq('元タスク')
        expect(task2.name).to eq('元タスク(コピー)')
        expect(task3.name).to eq('元タスク(コピー)(コピー)')
      end

      it 'nameに特殊文字が含まれる場合も正しく複製されること' do
        original_task = Task.create!(
          name: 'タスク🎉【重要】',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.name).to eq('タスク🎉【重要】(コピー)')
      end
    end

    describe 'エッジケース: その他の属性' do
      it 'explanationがnilの場合も複製が成功すること' do
        original_task = Task.create!(
          name: 'タスク',
          explanation: nil,
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.explanation).to be_nil
        expect(duplicated_task).to be_valid
      end

      it 'explanationが空文字列の場合も複製が成功すること' do
        original_task = Task.create!(
          name: 'タスク',
          explanation: '',
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.explanation).to eq('')
      end

      it 'explanationが長文の場合も正しく引き継がれること' do
        long_text = 'あ' * 200  # DB制限内の長さに調整
        original_task = Task.create!(
          name: 'タスク',
          explanation: long_text,
          genre: genre
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task.explanation).to eq(long_text)
      end
    end

    describe 'バリデーション' do
      it '複製後のタスクがvalidであること' do
        original_task = Task.create!(
          name: 'タスク',
          explanation: '説明',
          genre: genre,
          priority: :high
        )

        duplicated_task = original_task.duplicate

        expect(duplicated_task).to be_valid
      end

      it 'genre_idが正しく引き継がれてバリデーションを通過すること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre
        )

        duplicated_task = original_task.duplicate
        duplicated_task.save!

        expect(duplicated_task).to be_persisted
        expect(duplicated_task.genre).to eq(genre)
      end
    end

    describe 'タイムスタンプ' do
      it 'created_atが新しく設定されること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre
        )

        sleep 0.01  # 時間差を確保

        duplicated_task = original_task.duplicate
        duplicated_task.save!

        expect(duplicated_task.created_at).not_to eq(original_task.created_at)
        expect(duplicated_task.created_at).to be > original_task.created_at
      end

      it 'updated_atが新しく設定されること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre
        )

        sleep 0.01

        duplicated_task = original_task.duplicate
        duplicated_task.save!

        expect(duplicated_task.updated_at).not_to eq(original_task.updated_at)
        expect(duplicated_task.updated_at).to be > original_task.updated_at
      end
    end
  end
end
