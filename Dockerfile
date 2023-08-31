# syntax=docker/dockerfile:1
FROM scratch
ADD stage3 /
CMD ["bash"]
