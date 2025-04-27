#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

int main() {
    std::cout << "OpenCV version: " << CV_VERSION << std::endl;

    // Create a simple test image
    cv::Mat image(300, 300, CV_8UC3, cv::Scalar(255, 255, 255));

    // Draw a circle
    cv::circle(image, cv::Point(150, 150), 100, cv::Scalar(0, 0, 255), 3);

    // Display the image
    cv::imshow("Test Image", image);
    cv::waitKey(0);

    return 0;
}