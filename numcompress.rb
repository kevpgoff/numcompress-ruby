PRECISION_LOWER_LIMIT = 0
PRECISION_UPPER_LIMIT = 10

#set_trace_func proc { |event, file, line, id, binding, classname|
#  printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#}

def compress(series, precision = 3)
	last_num = 0
	result = ""
	if !series.kind_of?(Array)
		raise "Input list must be of type Array."
	end

		
	if !precision.kind_of?(Integer)
		raise "Precision must be of type Integer."
	end

	if precision < PRECISION_LOWER_LIMIT || precision > PRECISION_UPPER_LIMIT
		raise "Precision must be 0-10."
	end


	series.each do |item|
		if !item.kind_of?(Integer) && !item.kind_of?(Float)
			raise "Items in input list must be of type Integer or Float."
		end
	end

	result += (precision + 63).chr

	series.each do |num|
		diff = num - last_num
		diff = ((diff * (10 ** precision)).round())
		if diff < 0
			diff = ~(diff << 1)
		else
			diff = diff << 1
		end

		while diff >= 0x20
			result += (((0x20 | (diff & 0x1f)) + 63)).chr
			diff >>= 5
		end

		last_num = num
		result += ((diff + 63)).chr
	end
	return result
end

def decompress(text)
	result = []
	finalresult = []
	num_index = last_num = 0

	if text.kind_of?(String) == false
		raise "Decompression input must be of type String."
	end

	if text.empty? == true
		return result
	end

	precision = (text[num_index]).ord - 63 - 1
	num_index += 1

	if precision < PRECISION_LOWER_LIMIT || precision > PRECISION_UPPER_LIMIT
		raise "Precision error within string."
	end


	while num_index < text.length
		num_index, diff = decompress_number(text, num_index)
		last_num += diff
		result.push(last_num)
		puts(result)
	end

	result.each do |item|
		finalresult.push(((item * (10 ** (-precision))).round(precision)))
	end
	puts(finalresult)
	return finalresult

end

def decompress_number(text, num_index)
	result = 1
	shift = 0

	while true
		b = (text[num_index]).ord - 63 - 1
		num_index += 1
		result += b << shift
		shift += 5

		if b < 0x1f
			break
		end
	end


	if (result & 1) != 0 then return num_index, (~result >> 1) else return num_index, (result >> 1) end

end


testq = [234234234.456456, 777777777.1231231, 111434556.5667]
ok = compress(testq, 10)
puts(ok)
nice = decompress(ok)
puts(nice)
