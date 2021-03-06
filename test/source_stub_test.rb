require 'test_helper'

class SourceStubTest < Minitest::Test

  def test_row_size_check
    ss = Selekt::SourceStub.new(:a, :b)
    assert_raises(Selekt::StubError) { ss.add_row [1,2,3] }
    assert_equal 0, ss.rows.size

    ss.add_row [1,2]
    assert_equal 1, ss.rows.size

    ss.add_row [1]
    assert_equal 2, ss.rows.size
  end

  def test_add_row_as_hash
    s1 = Selekt::SourceStub.new(:a, :b)
    s2 = Selekt::SourceStub.new(:a, :b)

    s1.push [1, 2]
    s2.push a: 1, b: 2

    assert_equal s1, s2
  end

  def test_add_row_as_hash_with_nil_values
    s1 = Selekt::SourceStub.new(:a, :b)
    s2 = Selekt::SourceStub.new(:a, :b)

    s1.push [nil, 1]
    s2.push b: 1

    assert_equal s1, s2
  end  

  def test_add_rows
    s1 = Selekt::SourceStub.new(:a, :b)
    s1.add_rows([
      [1],
      { b: 2 }
    ])

    assert_equal [1, nil], s1.rows[0]
    assert_equal [nil, 2], s1.rows[1]
  end

  def test_sql_generation
    ss = Selekt::SourceStub.new(:a, :b)
    ss.add_row [nil, 2]
    assert_equal "SELECT NULL AS a, 2 AS b", ss.sql
    ss.add_row ['test', 10]
    ss.add_row ['test2', 123]
    assert_equal "SELECT NULL AS a, 2 AS b\nUNION ALL\nSELECT 'test', 10\nUNION ALL\nSELECT 'test2', 123", ss.sql
  end

  def test_value_quoting_for_sql
    ss = Selekt::SourceStub.new(:a, :b, :c)
    ss.add_row [DateTime.parse('2012-01-03 12:44:33'), Date.parse('2012-01-01'), "'"]
    assert_equal "SELECT '2012-01-03 12:44:33'::timestamp AS a, '2012-01-01'::date AS b, '''' AS c", ss.sql
  end
end