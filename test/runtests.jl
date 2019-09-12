using ForwardAutodiff
using Test: @test, @testset

@testset "FowardAutodiff.jl tests" begin
    @testset "Transcendental Functions" begin
        x = randn()
        @test isapprox(D(exp)(x), exp(x))
        @test isapprox(D(sin)(x), cos(x))
        @test isapprox(D(cos)(x), -sin(x))
        @test isapprox(D(tan)(x), sec(x)*sec(x))
    end

    @testset "sqrt" begin
        x = randn()

        # We need to be in the complex domain explicitly, or sqrt(x < 0) will error out
        @test isapprox(D(sqrt)(x + 0im), 1/(2*sqrt(x + 0im)))
    end

    @testset "Type promotion" begin
        @test isapprox(D(sin)(2//3), cos(2//3)) # Rationals
        @test isapprox(D(sin)(1+2im), cos(1+2im)) # Complex integers!
        @test isapprox(D(cos)(1.0+3.5im), -sin(1.0+3.5im)) # Boring complex floating point numbers
        @test isapprox(D(sqrt)(2), 1/(2*sqrt(2.0))) # Automatically promotes to the correct type.
    end

    @testset "compound function" begin
        freq = sqrt(2)

        function f(x)
            return exp(-x/pi)*sin(2.0*pi*freq*x)
        end
        fprime = D(f)

        function laborious_fprime(x)
            return exp(-x/pi)*(2*pi*freq*cos(2*pi*freq*x) - sin(2*pi*freq*x)/pi)
        end

        @test isapprox(fprime(3), laborious_fprime(3))
    end

    @testset "partials of simple function" begin
        function linear(x, m, b)
            return m*x+b
        end
        dldx = D(1, linear)
        dldslope = D(2, linear)
        dldintercept = D(3, linear)

        x = randn()
        m = randn()
        b = randn()
        @test isapprox(dldx(x,m,b), m)
        @test isapprox(dldslope(x,m,b), x)
        @test isapprox(dldintercept(x,m,b), 1)
    end

    @testset "Cycloid" begin
        function cycloid(t)
            return [cos(2*pi*t), sin(2*pi*t), t]
        end

        @test isapprox(D(cycloid)(0), [0.0, 2*pi, 1])

        t = randn()
        @test isapprox(D(cycloid)(t), [-2*pi*sin(2*pi*t), 2*pi*cos(2*pi*t), 1])
    end

    @testset "rotations in 2D" begin
        function R2(theta)
            return [[cos(theta), sin(theta)], [-sin(theta), cos(theta)]]
        end

        @test isapprox(D(R2)(0), [[0.0, 1.0], [-1.0, 0.0]])
    end
end
