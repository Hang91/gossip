defmodule TOPOLOGIES.Server do
	def start(i,j,k) do
		start_time = System.system_time(:millisecond)
		server_name = "0"
		Process.register self(), String.to_atom(server_name)
		topo = j
		algorithm = k
		for n <- 1..i do
			name = "#{n}"
			case algorithm do
				2 ->
					TOPOLOGIES.Pushsum_actor.start_link(name, i, topo)
				1 ->
					TOPOLOGIES.Gossip_actor.start_link(name, i, topo)
			end
		end

		case algorithm do
			1 -> 
				GenServer.cast String.to_atom("1"), {:rumor, "hello"}
				communicate1(%{}, i, start_time)
			2 -> 
				GenServer.call String.to_atom("1"), {:msg,0,0,"0"}
				communicate2(i, start_time)
		end
	end

	def communicate2(count, start_time) do
		receive do
			{:update} ->
				communicate2(count, start_time)
			{:stop} ->
				new_count = count - 1;
				IO.puts "count: #{new_count}"
				case new_count == 0 do
					true -> 
						IO.puts System.system_time(:millisecond) - start_time
					false -> communicate2(new_count, start_time)
				end
		end
	end

	def communicate1(map, count, start_time) do 
		receive do
			{:update, msg} ->
				case msg do
					{pid, num} -> 
						case num do
							10 ->
								new_count = count - 1
								IO.puts "count = #{new_count}"
								case new_count do
									0 -> 
										IO.puts System.system_time(:millisecond) - start_time
										IO.puts "all complete"
									_ -> 
										communicate1(map, new_count, start_time)
								end
							_ ->
								res = Map.fetch(map, pid)
								case res do
									{:ok, val} -> 
										Map.replace(map, pid, num)
									:error ->
										Map.put_new(map, pid, num)
								end
								communicate1(map, count, start_time)
						end

				end
		end
	end

end