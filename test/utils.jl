macro test_error(ex)
    quote
        err = try
            $(esc(ex))
            nothing
        catch err′
            Some(err′)
        end
        @test err isa Some{<:Exception}
        something(err)
    end
end

# const ∈ᵒᶜᶜᵘʳˢ = occursin
∈ᵉʳʳᵒʳ(needle, err) = occursin(needle, sprint(showerror, err))
