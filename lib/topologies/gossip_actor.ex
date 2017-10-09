defmodule TOPOLOGIES.Gossip_actor do
	use GenServer

	def start_link(name, process_num, topo) do
		msg = "abc"
		num = 0
		send_pid = self()
		GenServer.start_link(__MODULE__, [send_pid,msg,num,process_num,name,topo], [name: String.to_atom(name)])
	end 

	def handle_call({:start, new_msg}, from, [send_pid,msg,num,process_num,name,topo]) do
		{:reply, num, {send_pid,new_msg,num + 1,process_num,name,topo}}
	end


	def handle_cast({:rumor, new_msg}, [send_pid,msg,sum,process_num,name,topo]) do

		case sum do
			0 -> 
				case topo do
					1 ->
						neighbors = []
						neighbors = for n <- 1..process_num do
							neighbors = 
							case String.to_integer(name) != n do
								true -> 
									List.insert_at(neighbors,0,n)
								false ->
									neighbors
							end
						end

						pid = spawn fn -> send_message(name,new_msg,neighbors) end
						send String.to_atom("0"), {:update, {self(), sum + 1}}
						{:noreply, [pid,new_msg,sum + 1,process_num,name,topo]}
					2 ->
						neighbors = []
						line_num = round(:math.sqrt(process_num))
						offsets = [0,1,0,-1,1,0,-1,0]

						row = round(Float.floor((String.to_integer(name) - 1) / line_num))
						col = rem (String.to_integer(name) - 1),line_num
						neighbors = for n <- 0..3 do
							{offsetx,offsets} = List.pop_at(offsets,n*2)
							{offsety,offsets} = List.pop_at(offsets,n*2)
							next_row = row + offsetx
							next_col = col + offsety
							neighbors = 
							case next_row >= 0 && next_row < line_num && next_col >= 0 && next_col < line_num do
								true ->
									num = round((next_row) * line_num + next_col) + 1
									List.insert_at(neighbors,0,num)
								false ->
									neighbors
							end
						end
						pid = spawn fn -> send_message(name,new_msg,neighbors) end
						send String.to_atom("0"), {:update, {self(), sum + 1}}
						{:noreply, [pid,new_msg,sum + 1,process_num,name,topo]}
					3 ->
						neighbors = []
						name_num = String.to_integer(name)
						neighbors = 
						case name_num != 1 do
							true ->
								List.insert_at(neighbors,0,name_num - 1)
							false ->
								neighbors
						end

						neighbors = 
						case name_num != process_num do
							true ->
								List.insert_at(neighbors,0,name_num + 1)
							false ->
								neighbors
						end

						pid = spawn fn -> send_message(name,new_msg,neighbors) end
						send String.to_atom("0"), {:update, {self(), sum + 1}}
						{:noreply, [pid,new_msg,sum + 1,process_num,name,topo]}
					4 ->
						neighbors = []
						line_num = round(:math.sqrt(process_num))
						offsets = [0,1,0,-1,1,0,-1,0]

						row = round(Float.floor((String.to_integer(name) - 1) / line_num))
						col = rem (String.to_integer(name) - 1),line_num
						neighbors = for n <- 0..3 do
							{offsetx,offsets} = List.pop_at(offsets,n*2)
							{offsety,offsets} = List.pop_at(offsets,n*2)
							next_row = row + offsetx
							next_col = col + offsety
							neighbors = 
							case next_row >= 0 && next_row < line_num && next_col >= 0 && next_col < line_num do
								true ->
									num = round((next_row) * line_num + next_col) + 1
									List.insert_at(neighbors,0,num)
								false ->
									neighbors
							end
						end

						not_random_neighbors = MapSet.new(List.flatten(neighbors))
						not_random_neighbors = MapSet.put(not_random_neighbors, String.to_integer(name))
						
						p_random_neighbors = []
						p_random_neighbors =
						for n <- 1..process_num do
							p_random_neighbors = 
							case MapSet.member?(not_random_neighbors,n)do
								false ->
									List.insert_at(p_random_neighbors,0,n)
								true ->
									p_random_neighbors
							end
						end
						p_random_neighbors = List.flatten(p_random_neighbors)
						neighbors = List.insert_at(neighbors,0,Enum.random(p_random_neighbors))

						pid = spawn fn -> send_message(name,new_msg,neighbors) end
						send String.to_atom("0"), {:update, {self(), sum + 1}}
						{:noreply, [pid,new_msg,sum + 1,process_num,name,topo]}									
				end
			_ -> 
				send String.to_atom("0"), {:update, {self(), sum + 1}}
				if sum == 9 do
					stop_link(send_pid)
				end
				{:noreply, [send_pid,new_msg,sum + 1,process_num,name,topo]}	
		end
	end

	def stop_link(send_pid) do
		Process.exit(send_pid,:normal)
		Process.exit(self(),:normal)
	end

	def send_message(name,msg,neighbors) do
		new_neighbors = List.flatten(neighbors)
		i = Enum.random(new_neighbors)
		target = "#{i}"
		GenServer.cast String.to_atom(target), {:rumor, "hello"}
		send_message(name,msg,new_neighbors)
	end

end