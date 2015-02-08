class Simbody < Formula
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.1.tar.gz"
  sha256 "8e1f8faae6c1fd7d5f10707fa1c0152a5cab2178a20c5967cd2ed84a3f0325f4"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "Simbody.h"
			using namespace SimTK;
			int main() {
			    // Define the system.
			    MultibodySystem system;
			    SimbodyMatterSubsystem matter(system);
			    GeneralForceSubsystem forces(system);
			    Force::Gravity gravity(forces, matter, -YAxis, 9.8);

			    // Describe mass and visualization properties for a generic body.
			    Body::Rigid bodyInfo(MassProperties(1.0, Vec3(0), UnitInertia(1)));
			    bodyInfo.addDecoration(Transform(), DecorativeSphere(0.1));

			    // Create the moving (mobilized) bodies of the pendulum.
			    MobilizedBody::Pin pendulum1(matter.Ground(), Transform(Vec3(0)),
			            bodyInfo, Transform(Vec3(0, 1, 0)));
			    MobilizedBody::Pin pendulum2(pendulum1, Transform(Vec3(0)),
			            bodyInfo, Transform(Vec3(0, 1, 0)));

			    // Set up visualization.
			    Visualizer viz(system);
			    system.addEventReporter(new Visualizer::Reporter(viz, 0.01));

			    // Initialize the system and state.
			    State state = system.realizeTopology();
			    pendulum2.setRate(state, 5.0);

			    // Simulate for 20 seconds.
			    RungeKuttaMersonIntegrator integ(system);
			    TimeStepper ts(system, integ);
			    ts.initialize(state);
			    ts.stepTo(20.0);
			}
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-o", "test"
    assert `./test`.include?(version)
  end
end
