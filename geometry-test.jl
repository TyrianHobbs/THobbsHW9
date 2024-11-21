using .Geometry
using Test

#Test Polygons
triangle = Polygon([Point2D(0, 0), Point2D(1, 0), Point2D(0, 1)])
rectangle = Polygon([Point2D(0, 0), Point2D(1, 0), Point2D(1, 2), Point2D(0, 2)])
parallelogram = Polygon([Point2D(0, 0), Point2D(1, 0), Point2D(2, 1), Point2D(1, 1)])

@testset "A - equality" begin
    @test Point2D(1, 2) == Point2D(1, 2)
    @test Point2D(1, 2) != Point2D(1, 3)

    @test Point3D(1, 2, 3) == Point3D(1, 2, 3)
    @test Point3D(1, 2, 3) != Point3D(1, 2, 4)

    @test Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1)]) == 
    Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1)]) #Polygon equals itself
    @test Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1)]) != 
    Polygon([Point2D(0,0), Point2D(1,1), Point2D(2,2)]) #Has different points
    @test Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1)]) != 
    Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1), Point2D(-1,1)]) #Same first 3 points, but longer
    @test Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1), Point2D(-1,1)]) != 
    Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1)]) #Same first 3 points, but shorter
end

@testset "B- Point2Ds are Point2D" begin
    @test isa(Point2D(1, 2), Point2D)
    @test isa(Point2D(1.0, 2.0), Point2D)
    @test isa(Point2D(1, 2.0), Point2D)

    @test isa(Point2D("(1, 2)"), Point2D)
    @test isa(Point2D("(1.0 , 2.0)"), Point2D)
    @test isa(Point2D("(1 ,2.0)"), Point2D)
end

@testset "C- Point2D strings parse correctly" begin
    @test Point2D("(1, 2)") == Point2D(1, 2)
    @test Point2D("(1.0, 2.0)") == Point2D(1.0, 2.0)
    @test Point2D("(1, 2.0)") == Point2D(1, 2.0)    
end

@testset "D- Point2Ds are not Point3Ds" begin
    @test !isa(Point2D(1, 2), Point3D)
    @test !isa(Point2D(1.0, 2.0), Point3D)
    @test !isa(Point2D(1, 2.0), Point3D)
end

@testset "E- Polygons are Polygon" begin
    @test isa(triangle, Polygon) #Triangle, default
    @test isa(Polygon([0, 0.0, 1, 0, 1.0, 4, 0, 4]), Polygon) #Rectangle, vector of reals
    @test isa(Polygon(0, 0, 1, 0, 2, 1, 1, 1), Polygon) #Paralellogram, many real inputs
    @test isa(Polygon("(0, 0.0); (19, 21); (-3, -17.3)"), Polygon) 
end

@testset "F- Polygon Constructors Make Same Polygon" begin
    @test Polygon([0, 0.0, 1, 0, 1.0, 4, 0, 4]) == Polygon([Point2D(0, 0.0), Point2D(1, 0), Point2D(1.0, 4), Point2D(0, 4)])
    @test Polygon(0, 0, 1, 0, 2, 1, 1, 1) == Polygon([Point2D(0, 0), Point2D(1,0), Point2D(2,1), Point2D(1,1)])
    @test Polygon("(0, 0.0); (19, 21); (-3, -17.3)") == Polygon([Point2D(0, 0.0), Point2D(19, 21), Point2D(-3, -17.3)])
end

@testset "G- Polygons throw ArgumentErrors" begin
    @test_throws ArgumentError Polygon([Point2D(0,0), Point2D(1,0)]) #Less than 3 points
    @test_throws ArgumentError Polygon([0, 0, 1, 0]) #Less than 3 points
    @test_throws ArgumentError Polygon([0, 0, 1, 0, 1]) #Odd numbered vector
    @test_throws ArgumentError Polygon(0, 0, 1, 0) #Less than 3 points
    @test_throws ArgumentError Polygon(0, 0, 1, 0, 1) #Odd number of arguments
end

@testset "H- distance matches known distances" begin
    @test isapprox(distance(Point2D(0, 0), Point2D(0, 1)), 1)
    @test isapprox(distance(Point2D(0, 0), Point2D(1, 0)), 1)
    @test isapprox(distance(Point2D(0, 0), Point2D(1, 1)), sqrt(2))
    @test isapprox(distance(Point2D(-1, -1), Point2D(1, 1)), 2*sqrt(2))
end

@testset "I- perimeter matches known perimeters" begin
    @test isapprox(perimeter(triangle), 2+sqrt(2))
    @test isapprox(perimeter(rectangle), 6)
    @test isapprox(perimeter(parallelogram), 2+2*sqrt(2))
end

@testset "J- area matches known area" begin
    @test isapprox(area(triangle), 0.5)
    @test isapprox(area(rectangle), 2)
    @test isapprox(area(parallelogram), 1)
end