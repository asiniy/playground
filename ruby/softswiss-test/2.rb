array = [1,2,3,4,1,1,1,1,2,2,2,3]

def third_most_frequent_element(array)
  return nil unless array

  hash = {}

  array.each do |element|
    hash[element] ||= 0
    hash[element] += 1
  end

  hash.entries.sort_by { |v| v[0] }[2][0]
end

third_most_frequent_element
