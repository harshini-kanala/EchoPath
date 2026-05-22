import cv2

def draw_path(path, coordinates):

    image = cv2.imread("static/hospital_map.png")

    if image is None:

        print("hospital_map.png not found")

        return

    for i in range(len(path)-1):

        pt1 = coordinates[path[i]]

        pt2 = coordinates[path[i+1]]

        cv2.line(
            image,
            pt1,
            pt2,
            (0, 0, 255),
            5
        )

        cv2.circle(
            image,
            pt1,
            10,
            (255, 0, 0),
            -1
        )

        cv2.circle(
            image,
            pt2,
            10,
            (255, 0, 0),
            -1
        )

    cv2.imwrite(
        "static/output_map.png",
        image
    )

    print("Route map generated")